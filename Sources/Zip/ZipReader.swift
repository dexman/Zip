//
//  Dexter.swift
//  Zip
//
//  Created by Arthur Dexter on 4/17/21.
//  Copyright © 2021 Arthur Dexter. All rights reserved.
//

import Foundation
import Minizip

public class ZipReader {

    public struct Error: Swift.Error {}

    public init(_ url: URL) throws {
        guard let file = unzOpen64(url.path) else {
            throw Error()
        }
        self.file = file
    }

    deinit {
        unzClose(file)
    }

    public func entries() throws -> [String] {
        var ok: Int32 = UNZ_OK

        ok = unzGoToFirstFile(file)
        if ok != UNZ_OK && ok != UNZ_END_OF_LIST_OF_FILE {
            throw Error()
        }

        var entries: [String] = []
        while ok != UNZ_END_OF_LIST_OF_FILE {
            var fileInfo = unz_file_info64()
            ok = unzGetCurrentFileInfo64(file, &fileInfo, nil, 0, nil, 0, nil, 0)
            if ok != UNZ_OK {
                throw Error()
            }

            let fileNameCount = Int(fileInfo.size_filename) + 1
            var fileNameBuffer = [CChar](repeating: 0, count: fileNameCount)
            ok = unzGetCurrentFileInfo64(file, &fileInfo, &fileNameBuffer, UInt(fileNameCount), nil, 0, nil, 0)
            if ok != UNZ_OK {
                throw Error()
            }
            entries.append(String(cString: &fileNameBuffer))

            ok = unzGoToNextFile(file)
            if ok != UNZ_OK && ok != UNZ_END_OF_LIST_OF_FILE {
                throw Error()
            }
        }
        return entries
    }

    public func readEntry(_ fileName: String) throws -> Data {
        var ok = fileName.withCString { fileName in
            unzLocateFile(file, fileName, nil)
        }
        if ok == UNZ_END_OF_LIST_OF_FILE {
            throw CocoaError(.fileNoSuchFile)
        } else if ok != UNZ_OK {
            throw Error()
        }

        var fileInfo = unz_file_info64()
        ok = unzGetCurrentFileInfo64(file, &fileInfo, nil, 0, nil, 0, nil, 0)
        if ok != UNZ_OK {
            throw Error()
        }

        ok = unzOpenCurrentFile(file)
        if ok != UNZ_OK {
            throw Error()
        }
        defer { unzCloseCurrentFile(file) }

        guard fileInfo.uncompressed_size <= UInt64(Int.max) else {
            fatalError("Entry is too big to store in memory")
        }
        var buffer = Data(repeating: 0, count: Int(fileInfo.uncompressed_size))
        let readBytes = buffer.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
            unzReadCurrentFile(file, buffer.baseAddress, UInt32(buffer.count))
        }
        if readBytes < 0 {
            throw Error()
        }
        return buffer
    }

    private let file: unzFile
}
