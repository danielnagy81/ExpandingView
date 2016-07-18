# ExpandingView

ExpandingView is a ```UIView``` subclass which presents its image in expanding fashion with blurred background.

It is written in Swift 3 and currently works on iOS 10.
### Usage
Create an instance of ```ExpandingView```:
```swift
let expandingView = ExpandingView(image: image, dismissRect: cellRect)
```
Where ```image``` is the actual image that is going to be presented and ```dismissRect``` is the place where from/to the image will be faded in/to (its origin should be in the windows coordinate space).

Add it as a subview to some ```UIView```
```swift
view.addSubview(expandingView)
```
and finally call ```expand``` on the instance to let ```ExpandingView``` present its content.
```swift
expandingView.expand()
```
```ExpandingView``` uses its ```superview```s frame as its presenting area.
### Example 
![alt image](https://github.com/danielnagy81/ExpandingView/blob/master/ExpandingView.gif)
