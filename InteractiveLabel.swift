//
//  YPYTextView.swift
//
//  Created by Yu Pengyang on 9/22/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

public protocol InteractiveLabelDelegate: class {
    func view(textView: InteractiveLabel, ReceiveTouchAtCharIndex charIndex: Int)
    func viewReceiveTouchAtBlankRegion(textView: InteractiveLabel)
}

extension InteractiveLabelDelegate {
    func view(textView: InteractiveLabel, ReceiveTouchAtCharIndex charIndex: Int) {}
    
    func viewReceiveTouchAtBlankRegion(textView: InteractiveLabel) {}
}

@IBDesignable
public class InteractiveLabel: UIView {
    
    weak var delegate: InteractiveLabelDelegate? = nil

    public var font: UIFont! = UIFont.systemFontOfSize(17) {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var textColor: UIColor! = UIColor.darkTextColor() {
        didSet {
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var shadowColor: UIColor? = nil {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var shadowOffset: CGSize = CGSizeMake(0, -1) {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    public var textAlignment: NSTextAlignment = .Left {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var numberOfLines: Int = 1 {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var textContainerInsetLeft: CGFloat {
        get {
            return textContainerInset.left
        }
        set {
            textContainerInset.left = newValue
        }
    }
    
    @IBInspectable
    public var textContainerInsetTop: CGFloat {
        get {
            return textContainerInset.top
        }
        set {
            textContainerInset.top = newValue
        }
    }
    
    @IBInspectable
    public var textContainerInsetRight: CGFloat {
        get {
            return textContainerInset.right
        }
        set {
            textContainerInset.right = newValue
        }
    }
    
    @IBInspectable
    public var textContainerInsetBottom: CGFloat {
        get {
            return textContainerInset.bottom
        }
        set {
            textContainerInset.bottom = newValue
        }
    }
    
    public var textContainerInset: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var lineFragmentPadding: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    public var lineBreakMode: NSLineBreakMode = .ByTruncatingTail {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var text: String? {
        get {
            if let attrText = attributedText {
                return attrText.string
            }
            return nil
        }
        set {
            if let new = newValue {
                attributedText = NSAttributedString(string: new)
            } else {
                attributedText = nil
            }
        }
    }
    
    public var attributedText: NSAttributedString? {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    private var displayAttributedText: NSAttributedString? {
        if let attributedText = attributedText {
            return displayAttributedText(attributedText)
        }
        return nil
    }

    private var textStorage: NSTextStorage? = nil
    private var textContainer: NSTextContainer? = nil
    private var layoutManager: NSLayoutManager? = nil
    
    public override func drawRect(rect: CGRect) {
        if let attributedText = displayAttributedText {
            let textStorage = NSTextStorage(attributedString: attributedText)
            let textContainer = getTextContainer(rect.size)
            let layoutManager = getLayoutManager(textContainer)
            textStorage.addLayoutManager(layoutManager)
            let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
            let usedRect = layoutManager.usedRectForTextContainer(textContainer)
            let startPoint = CGPointMake(textContainerInset.left, textContainerInset.right)
            layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: startPoint)
            layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: startPoint)
            self.textStorage = textStorage
            self.layoutManager = layoutManager
            self.textContainer = textContainer
            self.textContainer!.size = usedRect.integral.size
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        if let attributedText = displayAttributedText {
            let textStorage = NSTextStorage(attributedString: attributedText)
            let textContainer = getTextContainer(size)
            let layoutManager = getLayoutManager(textContainer)
            textStorage.addLayoutManager(layoutManager)
            layoutManager.glyphRangeForTextContainer(textContainer)
            let rect = layoutManager.usedRectForTextContainer(textContainer)
            let containerSize = rect.integral.size
            return CGSizeMake(containerSize.width + textContainerInset.left + textContainerInset.right, containerSize.height + textContainerInset.top + textContainerInset.bottom)
        }
        return super.sizeThatFits(size)
    }
    
    public override func sizeToFit() {
        super.sizeToFit()
        frame.size = sizeThatFits(CGSizeMake(bounds.width, CGFloat.max))
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return sizeThatFits(CGSizeMake(bounds.width, CGFloat.max))
    }
    
    private func displayAttributedText(attributedText: NSAttributedString) -> NSAttributedString {
        let ret = NSMutableAttributedString(attributedString: attributedText)
        let range = NSMakeRange(0, ret.length)
        ret.addAttributes([NSForegroundColorAttributeName: textColor, NSFontAttributeName: font], range: range)
        let para = NSMutableParagraphStyle()
        para.alignment = textAlignment
        ret.addAttribute(NSParagraphStyleAttributeName, value: para, range: range)
        if let shadowColor = shadowColor {
            let shadow = NSShadow()
            shadow.shadowColor = shadowColor
            shadow.shadowOffset = shadowOffset
            ret.addAttribute(NSShadowAttributeName, value: shadow, range: range)
        }
        ret.fixAttributesInRange(range)
        return ret.copy() as! NSAttributedString
    }
    
    private func getTextContainer(size: CGSize) -> NSTextContainer {
        let textContainerSize = CGSizeMake(size.width - textContainerInset.left - textContainerInset.right, size.height - textContainerInset.top - textContainerInset.bottom)
        let textContainer = NSTextContainer(size: textContainerSize)
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineFragmentPadding = lineFragmentPadding
        return textContainer
    }
    
    private func getLayoutManager(container: NSTextContainer) -> NSLayoutManager {
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)
        return layoutManager
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first, textContainer = textContainer, layoutManager = layoutManager {
            let locationInView = touch.locationInView(self)
            let locationInTextContainer = CGPointMake(locationInView.x - textContainerInset.left, locationInView.y - textContainerInset.top)
            let glyphIndex = layoutManager.glyphIndexForPoint(locationInTextContainer, inTextContainer: textContainer)
            let glyphRect = layoutManager.boundingRectForGlyphRange(NSMakeRange(glyphIndex, 1), inTextContainer: textContainer)
            if glyphRect.contains(locationInTextContainer) {
                let charIndex = layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
                delegate?.view(self, ReceiveTouchAtCharIndex: charIndex)
            } else {
                delegate?.viewReceiveTouchAtBlankRegion(self)
            }
        }
    }
}
