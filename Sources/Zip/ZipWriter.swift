//
//  ZipWriter.swift
//  Zip
//
//  Created by Arthur Dexter on 4/17/21.
//  Copyright © 2021 Arthur Dexter. All rights reserved.
//

import Foundation
import Minizip

public class ZipWriter {
    public struct Error: Swift.Error {}

    public init(_ url: URL) throws {
        guard let file = zipOpen(url.path, APPEND_STATUS_CREATE) else {
            throw Error()
        }
        self.file = file
    }

    deinit {
        zipClose(file, nil)
    }

    public func writeEntry(_ fileName: String, _ data: Data) throws {
        var zipInfo: zip_fileinfo = zip_fileinfo()
        var ok = zipOpenNewFileInZip3(file, fileName, &zipInfo, nil, 0, nil, 0, nil,Z_DEFLATED, Z_DEFAULT_COMPRESSION, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, nil, 0)
        if ok != Z_OK {
            throw Error()
        }

        ok = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            zipWriteInFileInZip(file, buffer.baseAddress, UInt32(buffer.count))
        }
        if ok != Z_OK {
            throw Error()
        }

        ok = zipCloseFileInZip(file)
        if ok != Z_OK {
            throw Error()
        }
    }

    private let file: zipFile
}
