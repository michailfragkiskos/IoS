//
// 
// Copyright (c) 2015

import Foundation
import UIKit


//   DbData

public struct DbData {
    
    //// start ///
    public static func executeChange(sqlStr: String) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            error = SQLiteDB.sharedInstance.executeChange(sqlStr)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }//end
    
 ////start
    public static func executeChange(sqlStr: String, withArgs: [AnyObject]) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            error = SQLiteDB.sharedInstance.executeChange(sqlStr, withArgs: withArgs)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }//end
    
    //// start
    public static func executeMultipleChanges(sqlArr: [String]) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            for sqlStr in sqlArr {
                if let err = SQLiteDB.sharedInstance.executeChange(sqlStr) {
                    SQLiteDB.sharedInstance.close()
                    if let index = sqlArr .indexOf(sqlStr){//find(sqlArr, sqlStr) {
                //   if let index = indexOf(sqlArr, sqlStr) {
                        print("Error occurred on array item: \(index) -> \"\(sqlStr)\"")
                    }
                    error = err
                    return
                }
            }
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }
         public static func executeQuery(sqlStr: String) -> (result: [PDRow], error: Int?) {
        
        var result = [PDRow] ()
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error =  err
                return
            }
            (result, error) = SQLiteDB.sharedInstance.executeQuery(sqlStr)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return (result, error)
        
    }
    
    public static func executeQuery(sqlStr: String, withArgs: [AnyObject]) -> (result: [PDRow], error: Int?) {
        
        var result = [PDRow] ()
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            (result, error) = SQLiteDB.sharedInstance.executeQuery(sqlStr, withArgs: withArgs)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return (result, error)
        
    }
    
    public static func executeWithConnection(flags: DB.Flags, closure: ()->Void) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.openWithFlags(flags.toSQL()) {
                error = err
                return
            }
            closure()
            if let err = SQLiteDB.sharedInstance.closeCustomConnection() {
                error = err
                return
            }
        }
        putOnThread(task)
        return error
        
    }
    
    public static func escapeValue(obj: AnyObject?) -> String {
        return SQLiteDB.sharedInstance.escapeValue(obj)
    }
    
    public static func escapeIdentifier(obj: String) -> String {
        return SQLiteDB.sharedInstance.escapeIdentifier(obj)
    }
    
    public static func createTable(table: String, withColumnNamesAndTypes values: [String: DbData.DataType]) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            error = SQLiteDB.sharedInstance.createSQLTable(table, withColumnsAndTypes: values)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }
    
    public static func deleteTable(table: String) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            error = SQLiteDB.sharedInstance.deleteSQLTable(table)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }
    
    public static func existingTables() -> (result: [String], error: Int?) {
        
        var result = [String] ()
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            (result, error) = SQLiteDB.sharedInstance.existingTables()
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return (result, error)
        
    }
    
    public static func existingTableFields(table:String) -> (result:[String], error: Int?) {
        
      var params:[String] = [String]()
       let(result, error) = self.executeQuery("PRAGMA table_info(\(table))")
         for elements in result{
            if let asetid = elements["name"]?.asString(){
                params.append(asetid)
                
            }}
        
          return (params, error)
        
    }

    
    public static func errorMessageForCode(code: Int) -> String {
        return  PDError.errorMessageFromCode(code)
    }
    
    public static func databasePath() -> String {
        return SQLiteDB.sharedInstance.dbPath
    }
    
    public static func lastInsertedRowID() -> (rowID: Int, error: Int?) {
        
        var result = 0
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            result = SQLiteDB.sharedInstance.lastInsertedRowID()
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return (result, error)
        
    }
    
    public static func lastInsertedID(Table:String) -> Int {
        let (rowID,error) = self.executeQuery("select seq as lastid from sqlite_sequence where name='\(Table)'")
        if error == nil {
        if let a = rowID[0]["lastid"]?.asInt() {
            return a
            }
        }
        return -1
    }
    
    public static func numberOfRowsModified() -> (rowID: Int, error: Int?) {
        
        var result = 0
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            result = SQLiteDB.sharedInstance.numberOfRowsModified()
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return (result, error)
       
    }
    
    public static func createIndex(name name: String, onColumns: [String], inTable: String, isUnique: Bool = false) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            error = SQLiteDB.sharedInstance.createIndex(name, columns: onColumns, table: inTable, unique: isUnique)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }
    
    public static func removeIndex(indexName: String) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            error = SQLiteDB.sharedInstance.removeIndex(indexName)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }
    
    public static func existingIndexes() -> (result: [String], error: Int?) {
        
        var result = [String] ()
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            (result, error) = SQLiteDB.sharedInstance.existingIndexes()
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return (result, error)
        
    }
    
    public static func existingIndexesForTable(table: String) -> (result: [String], error: Int?) {
        
        var result = [String] ()
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            (result, error) = SQLiteDB.sharedInstance.existingIndexesForTable(table)
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return (result, error)
        
    }
    
    public static func transaction(transactionClosure: ()->Bool) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            if let err = SQLiteDB.sharedInstance.beginTransaction() {
                SQLiteDB.sharedInstance.close()
                error = err
                return
            }
            if transactionClosure() {
                if let err = SQLiteDB.sharedInstance.commitTransaction() {
                    error = err
                }
            } else {
                if let err = SQLiteDB.sharedInstance.rollbackTransaction() {
                    error = err
                }
            }
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }
    
    public static func savepoint(savepointClosure: ()->Bool) -> Int? {
        
        var error: Int? = nil
        let task: ()->Void = {
            if let err = SQLiteDB.sharedInstance.open() {
                error = err
                return
            }
            if let err = SQLiteDB.sharedInstance.beginSavepoint() {
                SQLiteDB.sharedInstance.close()
                error = err
                return
            }
            if savepointClosure() {
                if let err = SQLiteDB.sharedInstance.releaseSavepoint() {
                    error = err
                }
            } else {
                if let err = SQLiteDB.sharedInstance.rollbackSavepoint() {
                    print("Error rolling back to savepoint")
                    --SQLiteDB.sharedInstance.savepointsOpen
                    SQLiteDB.sharedInstance.close()
                    error = err
                    return
                }
                if let err = SQLiteDB.sharedInstance.releaseSavepoint() {
                    error = err
                }
            }
            SQLiteDB.sharedInstance.close()
        }
        putOnThread(task)
        return error
        
    }
    //end of class
        
    }


    // MARK: - SQLiteDB Class
    
   public class SQLiteDB {
        class var sharedInstance: SQLiteDB {
            struct Static {
                static var onceToken: dispatch_once_t = 0
                static var instance: SQLiteDB? = nil
            }
            dispatch_once(&Static.onceToken) {
                Static.instance = SQLiteDB()
            }
            return Static.instance!
        }
    
        /*
        class var sharedInstance: SQLiteDB {
            struct Singleton {
                static let instance = SQLiteDB()
            }
            return Singleton.instance
        }*/
        
        
        var sqliteDB: COpaquePointer = nil
        var dbPath = SQLiteDB.createPath()
        var inTransaction = false
        var isConnected = false
        var openWithFlags = false
        var savepointsOpen = 0
        let queue = dispatch_queue_create("DbData.DatabaseQueue", DISPATCH_QUEUE_SERIAL)
        
        
        // MARK: - Database Handling Functions
        
        //open a connection to the sqlite3 database
        func open() -> Int? {
            
            if inTransaction || openWithFlags || savepointsOpen > 0 {
                return nil
            }
            if sqliteDB != nil || isConnected {
                return nil
            }
            let status = sqlite3_open(dbPath.cStringUsingEncoding(NSUTF8StringEncoding)!, &sqliteDB)
            if status != SQLITE_OK {
                print("DbData Error -> During: Opening Database")
                print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                print("                 -> Details: \(errMsg)")
                }
                return Int(status)
            }
            isConnected = true
            return nil
            
        }
        
        //open a connection to the sqlite3 database with flags
        func openWithFlags(flags: Int32) -> Int? {
            
            if inTransaction {
                print("DbData Error -> During: Opening Database with Flags")
                print("                 -> Code: 302 - Cannot open a custom connection inside a transaction")
                return 302
            }
            if openWithFlags {
                print("DbData Error -> During: Opening Database with Flags")
                print("                 -> Code: 301 - A custom connection is already open")
                return 301
            }
            if savepointsOpen > 0 {
                print("DbData Error -> During: Opening Database with Flags")
                print("                 -> Code: 303 - Cannot open a custom connection inside a savepoint")
                return 303
            }
            if isConnected {
                print("DbData Error -> During: Opening Database with Flags")
                print("                 -> Code: 301 - A custom connection is already open")
                return 301
            }
            let status = sqlite3_open_v2(dbPath.cStringUsingEncoding(NSUTF8StringEncoding)!, &sqliteDB, flags, nil)
            if status != SQLITE_OK {
                print("DbData Error -> During: Opening Database with Flags")
                print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                print("                 -> Details: \(errMsg)")
                }
                return Int(status)
            }
            isConnected = true
            openWithFlags = true
            return nil
            
        }
        
        //close the connection to to the sqlite3 database
        func close() {
            
            if inTransaction || openWithFlags || savepointsOpen > 0 {
                return
            }
            if sqliteDB == nil || !isConnected {
                return
            }
            let status = sqlite3_close(sqliteDB)
            if status != SQLITE_OK {
                print("DbData Error -> During: Closing Database")
                print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                print("                 -> Details: \(errMsg)")
                }
            }
            sqliteDB = nil
            isConnected = false
            
        }
        
        //close a custom connection to the sqlite3 database
        func closeCustomConnection() -> Int? {
            
            if inTransaction {
                print("DbData Error -> During: Closing Database with Flags")
                print("                -> Code: 305 - Cannot close a custom connection inside a transaction")
                return 305
            }
            if savepointsOpen > 0 {
                print("DbData Error -> During: Closing Database with Flags")
                print("                -> Code: 306 - Cannot close a custom connection inside a savepoint")
                return 306
            }
            if !openWithFlags {
                print("DbData Error -> During: Closing Database with Flags")
                print("                -> Code: 304 - A custom connection is not currently open")
                return 304
            }
            let status = sqlite3_close(sqliteDB)
            sqliteDB = nil
            isConnected = false
            openWithFlags = false
            if status != SQLITE_OK {
                print("DbData Error -> During: Closing Database with Flags")
                print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                print("                 -> Details: \(errMsg)")
                }
                return Int(status)
            }
            return nil
            
        }

        //create the database path
        class func createPath() -> String {
            
            let docsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
            let databaseStr = "DbData.sqlite"
            let dbPath = (docsPath as NSString).stringByAppendingPathComponent(databaseStr)
            return String(dbPath)
            
        }
        
        //begin a transaction
        func beginTransaction() -> Int? {
            
            if savepointsOpen > 0 {
                print("DbData Error -> During: Beginning Transaction")
                print("                 -> Code: 501 - Cannot begin a transaction within a savepoint")
                return 501
            }
            if inTransaction {
                print("DbData Error -> During: Beginning Transaction")
                print("                 -> Code: 502 - Cannot begin a transaction within another transaction")
                return 502
            }
            if let error = executeChange("BEGIN EXCLUSIVE") {
                return error
            }
            inTransaction = true
            return nil
            
        }
        
        //rollback a transaction
        func rollbackTransaction() -> Int? {
            
            let error = executeChange("ROLLBACK")
            inTransaction = false
            return error
            
        }
        
        //commit a transaction
        func commitTransaction() -> Int? {
            
            let error = executeChange("COMMIT")
            inTransaction = false
            if let err = error {
                rollbackTransaction()
                return err
            }
            return nil
            
        }
        
        //begin a savepoint
        func beginSavepoint() -> Int? {
            
            if let error = executeChange("SAVEPOINT 'savepoint\(savepointsOpen + 1)'") {
                return error
            }
            ++savepointsOpen
            return nil
            
        }
        
        //rollback a savepoint
        func rollbackSavepoint() -> Int? {
            return executeChange("ROLLBACK TO 'savepoint\(savepointsOpen)'")
        }
        
        //release a savepoint
        func releaseSavepoint() -> Int? {
            
            let error = executeChange("RELEASE 'savepoint\(savepointsOpen)'")
            --savepointsOpen
            return error
            
        }
        
        //get last inserted row id
        func lastInsertedRowID() -> Int {
            let id = sqlite3_last_insert_rowid(sqliteDB)
            return Int(id)
        }
        
        //number of rows changed by last update
        func numberOfRowsModified() -> Int {
            return Int(sqlite3_changes(sqliteDB))
        }
        
        //return value of column
        func getColumnValue(statement: COpaquePointer, index: Int32, type: String) -> AnyObject? {
            
            switch type {
            case "INT", "INTEGER", "TINYINT", "SMALLINT", "MEDIUMINT", "BIGINT", "UNSIGNED BIG INT", "INT2", "INT8":
                if sqlite3_column_type(statement, index) == SQLITE_NULL {
                    return nil
                }
                return Int(sqlite3_column_int(statement, index))
            case "CHARACTER(20)", "VARCHAR(255)", "VARYING CHARACTER(255)", "NCHAR(55)", "NATIVE CHARACTER", "NVARCHAR(100)", "TEXT", "CLOB":
                let text = UnsafePointer<Int8>(sqlite3_column_text(statement, index))
                return String.fromCString(text)
            case "BLOB", "NONE":
                let blob = sqlite3_column_blob(statement, index)
                if blob != nil {
                    let size = sqlite3_column_bytes(statement, index)
                    return NSData(bytes: blob, length: Int(size))
                }
                return nil
            case "REAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "DECIMAL(10,5)":
                if sqlite3_column_type(statement, index) == SQLITE_NULL {
                    return nil
                }
                return Double(sqlite3_column_double(statement, index))
            case "BOOLEAN":
                if sqlite3_column_type(statement, index) == SQLITE_NULL {
                    return nil
                }
                return sqlite3_column_int(statement, index) != 0
            case "DATE", "DATETIME":
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let text = UnsafePointer<Int8>(sqlite3_column_text(statement, index))
                if let string = String.fromCString(text) {
                    return dateFormatter.dateFromString(string)
                }
                print("DbData Warning -> The text date at column: \(index)-\(type) could not be cast as a String, returning nil with statement \(statement)")
                return nil
            default:
                //print("DbData Warning -> Column: \(index)-\(type) is of an unrecognized type, returning nil with statement \(statement)")
                return nil
            }
            
        }
        
        
        // MARK: SQLite Execution Functions
        
        //execute a SQLite update from a SQL String
        func executeChange(sqlStr: String, withArgs: [AnyObject]? = nil) -> Int? {
            
            var sql = sqlStr
            if let args  = withArgs {
                let result = bind(args, toSQL: sql)
                if let error = result.error {
                    return error
                } else {
                    sql = result.string
                }
            }
            var pStmt: COpaquePointer = nil
            var status = sqlite3_prepare_v2(SQLiteDB.sharedInstance.sqliteDB, sql, -1, &pStmt, nil)
            if status != SQLITE_OK {
                print("DbData Error -> During: SQL Prepare")
                print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                print("                 -> Query \(sqlStr) ")
                if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                print("                 -> Details: \(errMsg)")
                }
                sqlite3_finalize(pStmt)
                return Int(status)
            }
            status = sqlite3_step(pStmt)
            if status != SQLITE_DONE && status != SQLITE_OK {
                print("DbData Error -> During: SQL Step")
                print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                print("                 -> Query \(sqlStr) ")
                if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                print("                 -> Details: \(errMsg)")
                }
                sqlite3_finalize(pStmt)
                return Int(status)
            }
            sqlite3_finalize(pStmt)
            return nil
            
        }
        
        //execute a SQLite query from a SQL String
        func executeQuery(sqlStr: String, withArgs: [AnyObject]? = nil) -> (result: [PDRow], error: Int?) {
            
            var resultSet = [PDRow]()
            var sql = sqlStr
            if let args = withArgs {
                let result = bind(args , toSQL: sql)
                if let err = result.error {
                    return (resultSet, err)
                } else {
                    sql = result.string
                }
            }
            var pStmt: COpaquePointer = nil
            var status = sqlite3_prepare_v2(SQLiteDB.sharedInstance.sqliteDB, sql, -1, &pStmt, nil)
            if status != SQLITE_OK {
                print("DbData Error -> During: SQL Prepare")
                print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                print("                 -> Query \(sqlStr) ")
                if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                print("                 -> Details: \(errMsg)")
                }
                sqlite3_finalize(pStmt)
                return (resultSet, Int(status))
            }
            var columnCount: Int32 = 0
            var next = true
            while next {
                status = sqlite3_step(pStmt)
                if status == SQLITE_ROW {
                    columnCount = sqlite3_column_count(pStmt)
                    var row = PDRow()
                    for var i: Int32 = 0; i < columnCount; ++i {
                        let columnName = String.fromCString(sqlite3_column_name(pStmt, i))!
                        if let columnType = String.fromCString(sqlite3_column_decltype(pStmt, i))?.uppercaseString {
                            if let columnValue: AnyObject = getColumnValue(pStmt, index: i, type: columnType) {
                                row[columnName] = PDColumn(obj: columnValue)
                            }
                        } else {
                            var columnType = ""
                            switch sqlite3_column_type(pStmt, i) {
                            case SQLITE_INTEGER:
                                columnType = "INTEGER"
                            case SQLITE_FLOAT:
                                columnType = "FLOAT"
                            case SQLITE_TEXT:
                                columnType = "TEXT"
                            case SQLITE3_TEXT:
                                columnType = "TEXT"
                            case SQLITE_BLOB:
                                columnType = "BLOB"
                            case SQLITE_NULL:
                                columnType = "NULL"
                            default:
                                columnType = "NULL"
                            }
                            if let columnValue: AnyObject = getColumnValue(pStmt, index: i, type: columnType) {
                                row[columnName] = PDColumn(obj: columnValue)
                            }
                        }
                    }
                    resultSet.append(row)
                } else if status == SQLITE_DONE {
                    next = false
                } else {
                    print("DbData Error -> During: SQL Step")
                    print("                 -> Code: \(status) - " + PDError.errorMessageFromCode(Int(status)))
                    print("                 -> Query \(sqlStr) ")
                    if let errMsg = String.fromCString(sqlite3_errmsg(SQLiteDB.sharedInstance.sqliteDB)) {
                    print("                 -> Details: \(errMsg)")
                    }
                    sqlite3_finalize(pStmt)
                    return (resultSet, Int(status))
                }
            }
            sqlite3_finalize(pStmt)
            return (resultSet, nil)
            
        }
        
    }
    
    
    // MARK: - PDRow
    
    public struct PDRow {
        
        var values = [String: PDColumn]()
        public subscript(key: String) -> PDColumn? {
            get {
                return values[key]
            }
            set(newValue) {
                values[key] = newValue
            }
        }
        
    }
    
    
    // MARK: - PDColumn
    
    public struct PDColumn {
        
        var value: AnyObject
        init(obj: AnyObject) {
            value = obj
        }
        
        //return value by type
        
        /**
        Return the column value as a String
        
        :returns:  An Optional String corresponding to the apprioriate column value. Will be nil if: the column name does not exist, the value cannot be cast as a String, or the value is NULL
        */
        public func asString() -> String? {
            return value as? String
        }
        
        /**
        Return the column value as an Int
        
        :returns:  An Optional Int corresponding to the apprioriate column value. Will be nil if: the column name does not exist, the value cannot be cast as a Int, or the value is NULL
        */
        public func asInt() -> Int? {
            return value as? Int
        }
        
        /**
        Return the column value as a Double
        
        :returns:  An Optional Double corresponding to the apprioriate column value. Will be nil if: the column name does not exist, the value cannot be cast as a Double, or the value is NULL
        */
        public func asDouble() -> Double? {
            return value as? Double
        }
        
        /**
        Return the column value as a Bool
        
        :returns:  An Optional Bool corresponding to the apprioriate column value. Will be nil if: the column name does not exist, the value cannot be cast as a Bool, or the value is NULL
        */
        public func asBool() -> Bool? {
            return value as? Bool
        }
        
        /**
        Return the column value as NSData
        
        :returns:  An Optional NSData object corresponding to the apprioriate column value. Will be nil if: the column name does not exist, the value cannot be cast as NSData, or the value is NULL
        */
        public func asData() -> NSData? {
            return value as? NSData
        }
        
        /**
        Return the column value as an NSDate
        
        :returns:  An Optional NSDate corresponding to the apprioriate column value. Will be nil if: the column name does not exist, the value cannot be cast as an NSDate, or the value is NULL
        */
        public func asDate() -> NSDate? {
            return value as? NSDate
        }
        
        /**
        Return the column value as an AnyObject
        
        :returns:  An Optional AnyObject corresponding to the apprioriate column value. Will be nil if: the column name does not exist, the value cannot be cast as an AnyObject, or the value is NULL
        */
        public func asAnyObject() -> AnyObject? {
            return value
        }
        
        /**
        Return the column value path as a UIImage
        
        :returns:  An Optional UIImage corresponding to the path of the apprioriate column value. Will be nil if: the column name does not exist, the value of the specified path cannot be cast as a UIImage, or the value is NULL
        */
     /*  public func asUIImage() -> UIImage? {
            
            if let path = value as? String{
                let docsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
                let imageDirPath = docsPath.stringByAppendingPathComponent("DbDataImages")
                let fullPath = imageDirPath.stringByAppendingPathComponent(path)
                if !NSFileManager.defaultManager().fileExistsAtPath(fullPath) {
                    print("DbData Error -> Invalid image ID provided")
                    return nil
                }
                if let imageAsData = NSData(contentsOfFile: fullPath) {
                    return UIImage(data: imageAsData)
                }
            }
            return nil
            
        }*/
      
}
  
// MARK: - Error Handling

private struct PDError {
    
}



// MARK: - Threading

 public extension DbData {
    
     static func putOnThread(task: ()->Void) {
        if SQLiteDB.sharedInstance.inTransaction || SQLiteDB.sharedInstance.savepointsOpen > 0 || SQLiteDB.sharedInstance.openWithFlags {
            task()
        } else {
            dispatch_sync(SQLiteDB.sharedInstance.queue) {
                task()
            }
        }
    }
    
 }


// MARK: - Escaping And Binding Functions

extension SQLiteDB {  // DbData.SQLiteDB {
    
    func bind(objects: [AnyObject], toSQL sql: String) -> (string: String, error: Int?) {
        
        var newSql = ""
        var bindIndex = 0
        var i = false
        for char in sql.characters {
            if char == "?" {
                if bindIndex > objects.count - 1 {
                    print("DbData Error -> During: Object Binding")
                    print("                -> Code: 201 - Not enough objects to bind provided")
                    return ("", 201)
                }
                var obj = ""
                if i {
                    if let str = objects[bindIndex] as? String {
                        obj = escapeIdentifier(str)
                    } else {
                        print("DbData Error -> During: Object Binding")
                        print("                -> Code: 203 - Object to bind as identifier must be a String at array location: \(bindIndex)")
                        return ("", 203)
                    }
                    newSql = newSql.substringToIndex(newSql.endIndex.predecessor())
                } else {
                    obj = escapeValue(objects[bindIndex])
                }
                newSql += obj
                ++bindIndex
            } else {
                newSql.append(char)
            }
            if char == "i" {
                i = true
            } else if i {
                i = false
            }
        }
        if bindIndex != objects.count {
            print("DbData Error -> During: Object Binding")
            print("                -> Code: 202 - Too many objects to bind provided")
            return ("", 202)
        }
        return (newSql, nil)
        
    }
    
    //return escaped String value of AnyObject
    func escapeValue(obj: AnyObject?) -> String {
        
        if let obj: AnyObject = obj {
            if obj is String {
                
                return "'\(escapeStringValue(obj as! String))'"
            }
            if obj is Double || obj is Int {
                return "\(obj)"
            }
            if obj is Bool {
                if obj as! Bool {
                    return "1"
                } else {
                    return "0"
                }
            }
            if obj is NSData {
                let str =  "\(obj)"
                var newStr = ""
                for char in str.characters {
                    if char != "<" && char != ">" && char != " " {
                        newStr.append(char)
                    }
                }
                return "X'\(newStr)'"
            }
            if obj is NSDate {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return "\(escapeValue(dateFormatter.stringFromDate(obj as! NSDate)))"
            }
          //if obj is UIImage {
            //    if let imageID = DB.saveUIImage(obj as! UIImage) {
            //        return "'\(escapeStringValue(imageID))'"
             //   }
               // print("DbData Warning -> Cannot save image, NULL will be inserted into the database")
           //     return "NULL"
           // }
            print("DbData Warning -> Object \"\(obj)\" is not a supported type and will be inserted into the database as NULL")
            return "NULL"
        }
          else {
           return "NULL"
        }
        
    }
    
    //return escaped String identifier
    func escapeIdentifier(obj: String) -> String {
        return "\"\(escapeStringIdentifier(obj))\""
    }
    
    
    //escape string
    func escapeStringValue(str: String) -> String {
        var escapedStr = ""
         for char in str.characters  {
            if char == "'" {
                escapedStr += "`"
            }else{
                escapedStr.append(char)
            }
        }
        return escapedStr
    }
    
    //escape string
    func escapeStringIdentifier(str: String) -> String {
        var escapedStr = ""
        for char in str.characters {
            if char == "\"" {
                escapedStr += "\""
            }
            escapedStr.append(char)
        }
        return escapedStr
    }


}

    
    
    



// MARK: - SQL Creation Functions

extension DbData {
    
    /**
    Column Data Types
    
    :param:  StringVal   A column with type String, corresponds to SQLite type "TEXT"
    :param:  IntVal      A column with type Int, corresponds to SQLite type "INTEGER"
    :param:  DoubleVal   A column with type Double, corresponds to SQLite type "DOUBLE"
    :param:  BoolVal     A column with type Bool, corresponds to SQLite type "BOOLEAN"
    :param:  DataVal     A column with type NSdata, corresponds to SQLite type "BLOB"
    :param:  DateVal     A column with type NSDate, corresponds to SQLite type "DATE"
    :param:  UIImageVal  A column with type String (the path value of saved UIImage), corresponds to SQLite type "TEXT"
    */
    public enum DataType {
        
        case StringVal
        case IntVal
        case DoubleVal
        case BoolVal
        case DataVal
        case DateVal
        case UIImageVal
        
        private func toSQL() -> String {
            
            switch self {
            case .StringVal, .UIImageVal:
                return "TEXT"
            case .IntVal:
                return "INTEGER"
            case .DoubleVal:
                return "DOUBLE"
            case .BoolVal:
                return "BOOLEAN"
            case .DataVal:
                return "BLOB"
            case .DateVal:
                return "DATE"
            }
        }
        
    }
    
    /**
    Flags for custom connection to the SQLite database
    
    :param:  ReadOnly         Opens the SQLite database with the flag "SQLITE_OPEN_READONLY"
    :param:  ReadWrite        Opens the SQLite database with the flag "SQLITE_OPEN_READWRITE"
    :param:  ReadWriteCreate  Opens the SQLite database with the flag "SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE"
    */
    public enum Flags {
        
        case ReadOnly
        case ReadWrite
        case ReadWriteCreate
        
        private func toSQL() -> Int32 {
            
            switch self {
            case .ReadOnly:
                return SQLITE_OPEN_READONLY
            case .ReadWrite:
                return SQLITE_OPEN_READWRITE
            case .ReadWriteCreate:
                return SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
            }
            
        }
        
    }
    
}


extension   SQLiteDB {//    DbData.SQLiteDB {
    
    //create a table
    func createSQLTable(table: String, withColumnsAndTypes values: [String: DbData.DataType]) -> Int? {
        
        var sqlStr = "CREATE TABLE \(table) (ID INTEGER PRIMARY KEY AUTOINCREMENT, "
        var firstRun = true
        for value in values {
            if firstRun {
                sqlStr += "\(escapeIdentifier(value.0)) \(value.1.toSQL())"
                firstRun = false
            } else {
                sqlStr += ", \(escapeIdentifier(value.0)) \(value.1.toSQL())"
            }
        }
        sqlStr += ")"
        return executeChange(sqlStr)
        
    }
    
    //delete a table
    func deleteSQLTable(table: String) -> Int? {
        let sqlStr = "DROP TABLE \(table)"
        return executeChange(sqlStr)
    }
    
    //get existing table names
    func existingTables() -> (result: [String], error: Int?) {
        let sqlStr = "SELECT name FROM sqlite_master WHERE type = 'table'"
        var tableArr = [String]()
        let results = executeQuery(sqlStr)
        if let err = results.error {
            return (tableArr, err)
        }
        for row in results.result {
            if let table = row["name"]?.asString() {
                tableArr.append(table)
            } else {
                print("DbData Error -> During: Finding Existing Tables")
                print("                -> Code: 403 - Error extracting table names from sqlite_master")
                return (tableArr, 403)
            }
        }
        return (tableArr, nil)
    }
    
    //create an index
    func createIndex(name: String, columns: [String], table: String, unique: Bool) -> Int? {
        
        if columns.count < 1 {
            print("DbData Error -> During: Creating Index")
            print("                -> Code: 401 - At least one column name must be provided")
            return 401
        }
        var sqlStr = ""
        if unique {
            sqlStr = "CREATE UNIQUE INDEX IF NOT EXISTS \(name) ON \(table) ("
        } else {
            sqlStr = "CREATE INDEX IF NOT EXISTS \(name) ON \(table) ("
        }
        var firstRun = true
        for column in columns {
            if firstRun {
                sqlStr += column
                firstRun = false
            } else {
                sqlStr += ", \(column)"
            }
        }
        sqlStr += ")"
        return executeChange(sqlStr)
        
    }
    
    //remove an index
    func removeIndex(name: String) -> Int? {
        let sqlStr = "DROP INDEX \(name)"
        return executeChange(sqlStr)
    }
    
    //obtain list of existing indexes
    func existingIndexes() -> (result: [String], error: Int?) {
        
        let sqlStr = "SELECT name FROM sqlite_master WHERE type = 'index'"
        var indexArr = [String]()
        let results = executeQuery(sqlStr)
        if let err = results.error {
            return (indexArr, err)
        }
        for res in results.result {
            if let index = res["name"]?.asString() {
                indexArr.append(index)
            } else {
                print("DbData Error -> During: Finding Existing Indexes")
                print("                -> Code: 402 - Error extracting index names from sqlite_master")
                print("Error finding existing indexes -> Error extracting index names from sqlite_master")
                return (indexArr, 402)
            }
        }
        return (indexArr, nil)
        
    }
    
    //obtain list of existing indexes for a specific table
    func existingIndexesForTable(table: String) -> (result: [String], error: Int?) {
        
        let sqlStr = "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = '\(table)'"
        var indexArr = [String]()
        let results = executeQuery(sqlStr)
        if let err = results.error {
            return (indexArr, err)
        }
        for res in results.result {
            if let index = res["name"]?.asString() {
                indexArr.append(index)
            } else {
                print("DbData Error -> During: Finding Existing Indexes for a Table")
                print("                -> Code: 402 - Error extracting index names from sqlite_master")
                return (indexArr, 402)
            }
        }
        return (indexArr, nil)
        
    }
    
}


// MARK: - PDError Functions

extension  PDError {         //DbData.PDError {
    
    //get the error message from the error code
    private static func errorMessageFromCode(errorCode: Int) -> String {
        
        switch errorCode {
            
            //no error
            
        case -1:
            return "No error"
            
            //SQLite error codes and descriptions as per: http://www.sqlite.org/c3ref/c_abort.html
        case 0:
            return "Successful result"
        case 1:
            return "SQL error or missing database"
        case 2:
            return "Internal logic error in SQLite"
        case 3:
            return "Access permission denied"
        case 4:
            return "Callback routine requested an abort"
        case 5:
            return "The database file is locked"
        case 6:
            return "A table in the database is locked"
        case 7:
            return "A malloc() failed"
        case 8:
            return "Attempt to write a readonly database"
        case 9:
            return "Operation terminated by sqlite3_interrupt()"
        case 10:
            return "Some kind of disk I/O error occurred"
        case 11:
            return "The database disk image is malformed"
        case 12:
            return "Unknown opcode in sqlite3_file_control()"
        case 13:
            return "Insertion failed because database is full"
        case 14:
            return "Unable to open the database file"
        case 15:
            return "Database lock protocol error"
        case 16:
            return "Database is empty"
        case 17:
            return "The database schema changed"
        case 18:
            return "String or BLOB exceeds size limit"
        case 19:
            return "Abort due to constraint violation"
        case 20:
            return "Data type mismatch"
        case 21:
            return "Library used incorrectly"
        case 22:
            return "Uses OS features not supported on host"
        case 23:
            return "Authorization denied"
        case 24:
            return "Auxiliary database format error"
        case 25:
            return "2nd parameter to sqlite3_bind out of range"
        case 26:
            return "File opened that is not a database file"
        case 27:
            return "Notifications from sqlite3_log()"
        case 28:
            return "Warnings from sqlite3_log()"
        case 100:
            return "sqlite3_step() has another row ready"
        case 101:
            return "sqlite3_step() has finished executing"
            
            //custom DbData errors
            
            //->binding errors
            
        case 201:
            return "Not enough objects to bind provided"
        case 202:
            return "Too many objects to bind provided"
        case 203:
            return "Object to bind as identifier must be a String"
            
            //->custom connection errors
            
        case 301:
            return "A custom connection is already open"
        case 302:
            return "Cannot open a custom connection inside a transaction"
        case 303:
            return "Cannot open a custom connection inside a savepoint"
        case 304:
            return "A custom connection is not currently open"
        case 305:
            return "Cannot close a custom connection inside a transaction"
        case 306:
            return "Cannot close a custom connection inside a savepoint"
            
            //->index and table errors
            
        case 401:
            return "At least one column name must be provided"
        case 402:
            return "Error extracting index names from sqlite_master"
        case 403:
            return "Error extracting table names from sqlite_master"
            
            //->transaction and savepoint errors
            
        case 501:
            return "Cannot begin a transaction within a savepoint"
        case 502:
            return "Cannot begin a transaction within another transaction"
            
            //unknown error
            
        default:
            //what the fuck happened?!?
            return "Unknown error"
        }
        
    }
}

    
public typealias DB = DbData;



