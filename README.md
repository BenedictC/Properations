# Properations

Properations is a concurrency framework. It provides:
- Future and promises based concurrency
- Integration with `(NS)Operation` infrastructure


## Futures & Promises: A Quick Intro

Futures and promises are a technique for managing asynchronous code.

### What is a future?

A future is an object that will at some point in the future contain a value. Without futures a function that returns its result asynchronously could be written like so:

```swift
func asynchronousMethod(completionHandler: @escaping (Bool) -> Void)
```

The same function written using futures could look like this:

```swift
func asynchronousMethod() -> Future<Bool>
```

The use of an object to reperesent the completion handler allows us to take advantage of other object orientated techniques.

The result of the future is a property of the future:
```swift
let future = asynchronousMethod()
guard let result = future.result else {
    print("Future is not fulfilled.")
}
switch result {
case .success(let value):
    print("Success! \(value)")
case .failure(let error):
    print("Failure! \(error)")
}
```

The above example leaves a key aspect of futures unexplained: how do we know when the future has been fulfilled? Futures have methods for responding to completion. These methods all return another future which means that they can be chained:

```swift
let future = asynchronousMethod()
    .onSuccess { value in
        print("Success! \(value)")
    }
    .onFailure { error in
        print("Failure! \(error)")
}
```

There are methods for transforming and combining results, errors recovery, delaying and creating interdependencies between futures.


### What is a promise?

All promises are futures and all futures are promises. Confused? Thought so. The terms future and promise refer the context in which the future/promise object is being used. In the example of a future described above we only looked at how the data was recieved and that is why we used the term future. The data must also be transmitted and that is when we refer to the object as a promise. Let's flesh out the function above:

```swift
func asynchronousMethod() -> Future<Bool> {
    let promise = Promises.make(promising: Bool.self)
    promise.succeed(with: true)
    return promise
}
```
`Promise` is implemented as a subclass of `Future` (and `Future` is a subclass of `Operation`). The interface of `Future` contains only methods for reading the result (and `cancel()` which it inherits from `Operation`), the interface of `Promise` adds methods for fulfilling the result, specifically:

- `.fulfill(with result: FutureResult<Success>)`
- `.succeed(with value: Success)`
- `.fail(with error: Error)`


### Other details

- By default any closures passed to `Properations` is executed on the main thread. If a method takes a closure argument then it will also take an execution queue argument which defaults to `OperationQueue.main`.


## Examples

### Wrapping a completion closure

Wrapping a method that uses a completion closure is a common use for promises. This example wraps the `dataTask` method of `URLSession`.

```swift
enum DataFetchError: Error {
    case  missingData
}

func fetchData(from url: URL, using urlSession: URLSession = .default) -> Future<Data> {
    let promise = Promises.make(promising: Data.self)
    let task = urlSession.dataTask { response, data, error in
        do {
            if let error = error {
                throw error
            }
            guard let data = data else {
                throw DataFetchError.missingData
            }
            promise.succeed(with: data)
        } catch {
            promise.fail(with: error)
        }
    }
    task.resume()
    return promise
}
```

Things to note: 
- The promise is created via one of the `Promises.make` factory methods. These methods provide 2 advantages over directly initalising a promise with `Promise.init`:
    1. In addition to creating the object, the factory methods also enqueue the promise on `Promises.defaultOperationQueue`.
    TODO
    2. `Promise` is a generic class so the constrants must be specified. Specifing constrants can become unwieldy and reduces readability. The `Promises` namespace is not generic so result type is specified as a parameter rather than a generic. (The factory methods are also avalible on `Promise` )
- The return type is `Future`, not `Promise`. This keeps the scope of mutablity to a minimum.
- The use of `do`/`catch` to simplifies the control flow.
- There is no explicit threading. The promise can be fulfilled from any thread (`dataTask()` makes no mention as to which thread the its completion handler will be executed on) and any future that follow on from it (see the next example) will not be affected by the thread that the promise is fulfilled on.


### Mapping values, using a custom queue and failure recovery

Once a future is fulfilled it is common to act on the result. This example builds on the previous and shows how futures can be used to transform a value.

```swift

func generateFauxPainting(from image: UIImage) throws -> UIImage {
    ...
}

let imageProcessingQueue = OperationQueue()
let defaultProfileImage: UIImage
let profileImageView: UIImageView

func updateProfileImageWithImage(atImageURL imageURL: URL) {
    fetchData(imageURL)
        .compactMapToValue(on: imageProcessingQueue) { data in
            UIImage(data: $0)
        }    
        .mapToValue(on: imageProcessingQueue) { image in
            try generateFauxPainting(from: image)
        }
        .recover { _ in
            return self.defaultProfileImage 
        }
        .onSuccess {
            self.profileImageView.image = $0
    }
}
```

Things to note: 
- By default any future that takes a closure will execute the closure on `OperationQueue.main`. The two futures that execute processor intesive closures, `compactMapToValue` and `mapToValue`, are specified to execute on `imageProcessingQueue` thus preventing the main queue from being blocked.
- (All futures are enqueued on `Promises.defaultOperationQueue`. This is an implementation detail and is of little consequence to the usage of futures.)
- We do not need to hold a reference to any of the futures. 
- `compactMapToValue` will throw an error, `ProperationsError.compactMapReturnedNil` if `UIImage(data:)` returns `nil`.
- `mapToValue` throws the error thown by `generateFauxPainting(from:)`.
- Most futures only execute if the value they are waiting for succeeds. 
- Errors are handled in one place, specifically the `recover` future.


### Advanced mapping and combining futures

TODO

```swift
struct ArtistProfile: Codable {
    let albumRefs: [URL]
    // ...
}


struct Album: Codable {
    // ...
}


func fetchArtistProfileAndAlbumsForArtist(at artistURL: URL) -> Future<(ArtistProfile, [Album])> {
    let artistProfileFuture = fetchData(from: artistURL)
        .mapToValue { try JSONDecoder().decode(ArtistProfile.self, from: $0) }
     
     let albumsFuture = artistProfileFuture
        .mapToValue { $0.albumRefs }
        .mapElementsToFuture { fetchData($0) }
        .mapElementsToValue { JSONDecoder().decode(Album.self, from: $0) }
        
    return Promises.combine(artistProfileFuture, albumsFuture)
}
```

Things to note:
- TODO


### Blocking Promises (Advanced)

An unfulfilled promise does not block the `OperationQueue` it is enqueued on (this is achieved by `.isReady` returning `false` until the result is fulfilled). This behaviour means that promises enqueued on the main operation queue do not cause a deadlock (although by default promises are enqueue on `Promises.defaultOperationQueue`, not `OperationQueue.main`.) 

Occasionally it is useful for a promise to block the queue while the work to fulfill the promise is being performed. This behaviour is more akin to standard `Operation` subclass and it can be achieved by using a `BlockingPromise`. 

An example for when this would be useful would be a MacOS app that manages a serial queue of `Process` instances (terminal commands).  `Process` has the  `var terminationHandler` which provides an asynchronous completion callback.      

```swift
class ProcessCoordinator {

    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()


    func enqueue(process: Process) -> Future<Process> {
        return Promises.makeBlocking(on: queue, promising: Void.self) { promise in
            process.terminationHandler {
                promise.succeed(with: process)
            }
            process.run()
        }
    }
}
```

Things to note:
- We are using a blocking promise which requires the use of a private operation queue.
- TODO
