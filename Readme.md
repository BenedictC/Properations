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

### Wrapping an completion closure

```swift
func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) -> Future<[CLPlacemark]> {
    let promise = Promise.make(promising: [CLPlacemark].self)
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
        do {
            if let error = error {
                throw error
            }
            let value = placemarks ?? []
            promise.succeed(with: value)
        } catch {
            promise.fail(with: error)
        }
    }    
    return promise
}
```
Things to note: 
- The return type is `Future` and not `Promise`. This keeps the scope of mutablity to a minimum.
- The use of `do`/`catch` to simplifies the control flow.
