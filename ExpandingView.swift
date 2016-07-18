import UIKit

class ExpandingView: UIView {
    
    var dragThreshold: CGFloat = 100
    var animationDuration: TimeInterval =  0.5
    var animationDamping: CGFloat = 0.5
    
    private let imageDismissRect: CGRect
    
    private let blurView = UIVisualEffectView()
    private let imageView = UIImageView()
    
    private var lastTouchPosition: CGPoint?
    
    private var animator: Animator?
    
    init(image: UIImage, dismissRect: CGRect) {
        self.imageView.image = image
        self.imageDismissRect = dismissRect
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func expand() {
        setupConstraintsToFullScreen()
        expandAnimation()
    }
    
    func adjustToFullSrceen() {
        setupConstraintsToFullScreen()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Object is destroyed!")
    }
}

//Setup
extension ExpandingView {
    
    private func setup() {
        addSubview(blurView)
        addSubview(imageView)
        setupBlurView()
        setupConstraints()
        setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        setupPanGestureRecognizer()
        setupTapGestureRecognizer()
    }
    
    private func setupPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .prominent)
        blurView.effect = blurEffect
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        setupBlurViewConstraints()
        setupImageViewConstraints()
    }
    
    private func setupBlurViewConstraints() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: topAnchor, constant: -dragThreshold).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: dragThreshold).isActive = true
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -dragThreshold).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: dragThreshold).isActive = true
    }
    
    private func setupImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        setupImageConstraints()
    }
    
    private func setupImageConstraints() {
        
        guard let image = imageView.image else {
            fatalError("Image is not set!")
        }
        
        if animator == nil {
            animator = Animator()
        }
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: image.size.width)
        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: image.size.height)
        
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        
        animator?.imageViewWidthConstraint = widthConstraint
        animator?.imageViewHeightConstraint = heightConstraint
    }
    
    private func setupConstraintsToFullScreen() {
        
        guard let superview = superview else {
            return
        }
        let leadingConstraint = leadingAnchor.constraint(equalTo: superview.leadingAnchor)
        let trailingConstraint = trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        let topConstraint = topAnchor.constraint(equalTo: superview.topAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        topConstraint.isActive = true
        bottomConstraint.isActive = true
        
        setupAnimator(withTopConstraint: topConstraint, withBottomConstraint: bottomConstraint, withLeadingConstraint: leadingConstraint, withTrailingConstraint: trailingConstraint)
    }
    
    private func setupAnimator(withTopConstraint topConstraint: NSLayoutConstraint, withBottomConstraint bottomConstraint: NSLayoutConstraint, withLeadingConstraint leadingConstraint: NSLayoutConstraint, withTrailingConstraint trailingConstraint: NSLayoutConstraint) {
        
        if let animator = animator {
            animator.topConstraint = topConstraint
            animator.bottomConstraint = bottomConstraint
            animator.leadingConstraint = leadingConstraint
            animator.trailingConstraint = trailingConstraint
        } else {
            animator = Animator(topConstraint: topConstraint, bottomConstraint: bottomConstraint, leadingConstraint: leadingConstraint, trailingConstraint: trailingConstraint)
        }
    }
}

//Gestures
extension ExpandingView {
    
    @objc private func panAction(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        if panGestureRecognizer.state == .changed {
            moveView(withPanGestureRecognizer: panGestureRecognizer)
            fadeEffect()
            
        } else if panGestureRecognizer.state == .began {
            lastTouchPosition = panGestureRecognizer.location(in: nil)
            
        } else if panGestureRecognizer.state == .ended {
            endMoving()
        }
    }
    
    private func moveView(withPanGestureRecognizer panGestureRecognizer: UIPanGestureRecognizer) {
        
        guard let lastTouchPosition = lastTouchPosition else {
            fatalError("There was no last position!")
        }
        
        let currentTouchPosition = panGestureRecognizer.location(in: nil)
        let deltaX = currentTouchPosition.x - lastTouchPosition.x
        let deltaY = currentTouchPosition.y - lastTouchPosition.y
        
        animator?.move(withDeltaX: deltaX, withDeltaY: deltaY)
        
        self.lastTouchPosition = currentTouchPosition
    }
    
    private func fadeEffect() {
        let viewCurrentPosition = self.convert(CGPoint.zero, to: nil)
        let distance = sqrt(pow(viewCurrentPosition.x, 2) + pow(viewCurrentPosition.y, 2))
        
        if distance > dragThreshold {
            setAlpha(0)
            
        } else if distance > 0 {
            let ratio = 1 - distance / dragThreshold
            setAlpha(ratio)
            
        } else {
            setAlpha(1)
        }
    }
    
    private func setAlpha(_ alpha: CGFloat) {
        blurView.alpha = alpha
    }
}

//Animations
extension ExpandingView {
    
    private func expandAnimation() {
        
        guard let superview = superview, imageSize = imageView.image?.size else {
            fatalError("Superview or image not set!")
        }
        setAlpha(0)
        animator?.changeImageSize(toSize: imageDismissRect.size)
        superview.setNeedsLayout()
        superview.layoutIfNeeded()
        
        let deltaPoint = distanceOfCenterOfImageViewAndDismissRect()
        animator?.move(withDeltaX: deltaPoint.x, withDeltaY: deltaPoint.y)
        superview.setNeedsLayout()
        superview.layoutIfNeeded()
        
        animator?.resetContraintsToOriginalPosition()
        animator?.changeImageSize(toSize: imageSize)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animationDamping, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.setAlpha(1)
            self?.superview?.layoutIfNeeded()
            
            }, completion: { [weak self] _ in
                self?.setAlpha(1)
            })
    }
    
    private func endMoving() {
        let viewEndPosition = self.convert(CGPoint.zero, to: nil)
        let distance = sqrt(pow(viewEndPosition.x, 2) + pow(viewEndPosition.y, 2))
        
        if distance > dragThreshold {
            dismissView()
        } else {
            animator?.resetContraintsToOriginalPosition()
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animationDamping, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.setAlpha(1)
                self?.superview?.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    self?.setAlpha(1)
                })
        }
        lastTouchPosition = nil
    }
    
    @objc private func dismissView() {
        let deltaPoint = distanceOfCenterOfImageViewAndDismissRect()
        
        animator?.move(withDeltaX: deltaPoint.x, withDeltaY: deltaPoint.y)
        animator?.changeImageSize(toSize: imageDismissRect.size)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animationDamping, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.setAlpha(0)
            
            self?.superview?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.removeFromSuperview()
            })
    }
    
    private func distanceOfCenterOfImageViewAndDismissRect() -> CGPoint {
        
        let imageViewCurrentRect = imageView.convert(CGRect(origin: CGPoint.zero, size: imageView.frame.size), to: nil)
        let originDeltaX = (imageDismissRect.origin.x + imageDismissRect.size.width / 2) - (imageViewCurrentRect.origin.x + imageViewCurrentRect.size.width / 2)
        let originDeltaY = (imageDismissRect.origin.y + imageDismissRect.size.height / 2) - (imageViewCurrentRect.origin.y + imageViewCurrentRect.size.height / 2)
        let distancePoint = CGPoint(x: originDeltaX, y: originDeltaY)
        return distancePoint
    }
}

private class Animator {
    
    weak private var imageViewWidthConstraint: NSLayoutConstraint?
    weak private var imageViewHeightConstraint: NSLayoutConstraint?
    
    weak private var topConstraint: NSLayoutConstraint?
    weak private var bottomConstraint: NSLayoutConstraint?
    weak private var leadingConstraint: NSLayoutConstraint?
    weak private var trailingConstraint: NSLayoutConstraint?
    
    init() {}
    
    init(topConstraint: NSLayoutConstraint, bottomConstraint: NSLayoutConstraint, leadingConstraint: NSLayoutConstraint, trailingConstraint: NSLayoutConstraint) {
        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
        self.leadingConstraint = leadingConstraint
        self.trailingConstraint = trailingConstraint
    }
    
    func move(withDeltaX deltaX: CGFloat, withDeltaY deltaY: CGFloat) {
        topConstraint?.constant += deltaY
        bottomConstraint?.constant += deltaY
        leadingConstraint?.constant += deltaX
        trailingConstraint?.constant += deltaX
    }
    
    func resetContraintsToOriginalPosition() {
        topConstraint?.constant = 0
        bottomConstraint?.constant = 0
        leadingConstraint?.constant = 0
        trailingConstraint?.constant = 0
    }
    
    func changeImageSize(toSize size: CGSize) {
        imageViewWidthConstraint?.constant = size.width
        imageViewHeightConstraint?.constant = size.height
    }
}
