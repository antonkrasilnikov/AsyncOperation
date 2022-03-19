import Foundation

open class AsyncOperation: Operation {

    public typealias AsyncBlock = (@escaping () -> Void) -> Void

    open override var isAsynchronous: Bool {
        return true
    }

    var block: AsyncBlock

    public init(block: @escaping AsyncBlock) {
        self.block = block
        super.init()
    }

    var _isFinished: Bool = false

    open override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }

        get {
            return _isFinished
        }
    }

    var _isExecuting: Bool = false

    open override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }

        get {
            return _isExecuting
        }
    }

    open override func start() {
        isExecuting = true

        block{
            self.isExecuting = false
            self.isFinished = true
        }

    }
}

open class AsyncOperationQueue {
    
    unowned(unsafe) open var underlyingQueue: DispatchQueue? = nil
    
    private let _queue: OperationQueue = {
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .userInteractive
        return $0
    }(OperationQueue())
    
    public var isSuspended: Bool {
        set {
            _queue.isSuspended = newValue
        }
        get {
            _queue.isSuspended
        }
    }
    
    public var maxConcurrentOperationCount: Int {
        set {
            _queue.maxConcurrentOperationCount = newValue
        }
        get {
            _queue.maxConcurrentOperationCount
        }
    }
    
    public var qualityOfService: QualityOfService {
        set {
            _queue.qualityOfService = newValue
        }
        get {
            _queue.qualityOfService
        }
    }

    public func cancelAllOperations() {
        _queue.cancelAllOperations()
    }
    
    public func waitUntilAllOperationsAreFinished() {
        _queue.waitUntilAllOperationsAreFinished()
    }

    public var operations: [AsyncOperation] {
        _queue.operations.compactMap({ $0 as? AsyncOperation })
    }
    
    public var operationCount: Int {
        _queue.operationCount
    }
    
    public init(underlyingQueue: DispatchQueue? = nil) {
        self.underlyingQueue = underlyingQueue
    }
    
    public func add(operation block: @escaping (@escaping () -> Void) -> Void, name: String? = nil) {
        let operation = AsyncOperation { [weak self] completion in
            if let underlyingQueue = self?.underlyingQueue {
                underlyingQueue.async {
                    block(completion)
                }
            }else{
                block(completion)
            }
        }
        operation.name = name
        _queue.addOperation(operation)
    }
}
