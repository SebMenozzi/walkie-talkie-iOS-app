//
//  DYScrollRulerView.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 30/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import UIKit

fileprivate let TextRulerFont    = UIFont(name: "GothamRounded-Medium", size: 12)!
fileprivate let RulerLineColor   = UIColor.white
fileprivate let RulerGap         = 14
fileprivate let RulerLong        = 45
fileprivate let RulerShort       = 30
fileprivate let TriangleWidth    = 16
fileprivate let CollectionHeight = 80
fileprivate let TextColorWhiteAlpha: CGFloat = 1.0

fileprivate func alerts(vc:UIViewController, str:String){
    let alert = UIAlertController.init(title: "提醒", message: str, preferredStyle: UIAlertController.Style.alert)
    let action:UIAlertAction = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
        
    })
    alert.addAction(action)
    vc.present(alert, animated: true, completion: nil)
}

class TraingleView: UIView {
    
    var triangleColor:UIColor?
    
    override func draw(_ rect: CGRect) {
        UIColor.clear.set()
        UIRectFill(self.bounds)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint.init(x: 0, y: 0))
        context.addLine(to: CGPoint.init(x: TriangleWidth, y: 0))
        context.addLine(to: CGPoint.init(x: TriangleWidth/2, y: TriangleWidth/2))
        context.setLineCap(CGLineCap.butt)
        context.setLineJoin(CGLineJoin.bevel)
        context.closePath()
        
        triangleColor?.setFill()
        triangleColor?.setStroke()
        
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
}

/***************DY************分************割************线***********/

class DYRulerView: UIView {
    var minValue: Float = 0.0
    var maxValue: Float = 0.0
    var unit: String = ""
    var step: Float = 0.0
    var betweenNumber = 0
    
    override func draw(_ rect: CGRect) {
        let startX: CGFloat  = 0
        let lineCenterX = CGFloat(RulerGap)
        let shortLineY = rect.size.height - CGFloat(RulerLong)
        let longLineY = rect.size.height - CGFloat(RulerShort)
        let topY: CGFloat = 0
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(1.0)
        context?.setLineCap(CGLineCap.butt)
        context?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        for i in 0...betweenNumber {
            context?.move(to: CGPoint.init(x: startX+lineCenterX*CGFloat(i), y: topY))
            if i % betweenNumber == 0 {
                let num = Float(i) * step + minValue

                let numStr = String(format: "%.f", num)

                let attribute:Dictionary = [
                    NSAttributedString.Key.font: TextRulerFont,
                    NSAttributedString.Key.foregroundColor:UIColor.init(white: TextColorWhiteAlpha, alpha: 1.0)
                ]

                let width = numStr.boundingRect(
                    with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                    attributes: attribute,context: nil).size.width

                numStr.draw(in: CGRect(x: startX + lineCenterX * CGFloat(i) - width / 2, y: longLineY + 10, width: width, height: 14), withAttributes: attribute)

                context!.addLine(to: CGPoint.init(x: startX + lineCenterX * CGFloat(i), y: longLineY))
            } else {
                context!.addLine(to: CGPoint.init(x: startX + lineCenterX * CGFloat(i), y: shortLineY))
            }
            context!.strokePath()

        }
        
    }
}


class DYHeaderRulerView: UIView {
    
    var headerMinValue = 0
    var headerUnit = ""
    
    override func draw(_ rect: CGRect) {
        let longLineY = rect.size.height - CGFloat(RulerShort)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context?.setLineWidth(1.0)
        context?.setLineCap(CGLineCap.butt)
        
        context?.move(to: CGPoint.init(x: rect.size.width, y: 0))
        var numStr:NSString = NSString(format: "%d", headerMinValue)
        
        let attribute:Dictionary = [
            NSAttributedString.Key.font: TextRulerFont,
            NSAttributedString.Key.foregroundColor: UIColor.init(white: TextColorWhiteAlpha, alpha: 1.0)
        ]
        
        let width = numStr.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions(rawValue: 0), attributes: attribute, context: nil).size.width
        
        numStr.draw(in: CGRect.init(x: rect.size.width-width/2, y: longLineY + 10, width: width, height: 14), withAttributes: attribute)
        context?.addLine(to: CGPoint.init(x: rect.size.width, y: longLineY))
        context?.strokePath()
        
    }
}


class DYFooterRulerView: UIView {
    var footerMaxValue = 0
    var footerUnit = ""
    
    override func draw(_ rect: CGRect) {
        let longLineY = Int(rect.size.height) - RulerShort
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        context?.setLineWidth(1.0)
        context?.setLineCap(CGLineCap.butt)
        
        context?.move(to: CGPoint.init(x: 0, y: 0))
        var numStr: NSString = NSString(format: "%d%@", footerMaxValue,footerUnit)
        
        let attribute: Dictionary = [
            NSAttributedString.Key.font: TextRulerFont,
            NSAttributedString.Key.foregroundColor: UIColor(white: TextColorWhiteAlpha, alpha: 1.0)
        ]
        
        let width = numStr.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions(rawValue: 0), attributes: attribute, context: nil).size.width
        
        numStr.draw(in: CGRect.init(x: 0 - width / 2, y: CGFloat(longLineY + 10), width: width, height: CGFloat(14)), withAttributes: attribute)
        context?.addLine(to: CGPoint.init(x: 0, y: longLineY))
        context?.strokePath()
    }
}


protocol DYScrollRulerDelegate: NSObjectProtocol {
    func dyScrollRulerViewValueChange(rulerView:DYScrollRulerView,value:Float)
}

class DYScrollRulerView: UIView {

    weak var delegate: DYScrollRulerDelegate?
    
    var scrollByHand = true
    var triangleColor:UIColor? = nil
    var stepNum = 0
    private var redLine: UIImageView?
    private var fileRealValue: Float = 0.0
    var rulerUnit: String = ""
    var minValue: Float = 0.0
    var maxValue: Float = 0.0
    var step: Float = 0.0
    var betweenNum:Int = 0
    
    var currentVC: UIViewController?
    
    class func rulerViewHeight() -> Int {
        return 40 + 20 + CollectionHeight
    }
    
    init(frame: CGRect, tminValue: Float, tmaxValue: Float, tstep: Float, tunit: String, tNum: Int, viewcontroller: UIViewController) {
        super.init(frame: frame)
        
        minValue = tminValue
        maxValue = tmaxValue
        betweenNum = tNum
        step = tstep
        stepNum = Int((tmaxValue - tminValue)/step)/betweenNum
        rulerUnit = tunit
        currentVC = viewcontroller
        
        valueTextField.frame = CGRect(x: self.bounds.size.width / 2 - 50, y: 0, width: 100, height: 70)
        self.addSubview(self.valueTextField)

        lazyTriangle.frame = CGRect.init(
            x: self.bounds.size.width / 2 - 0.5 - CGFloat(TriangleWidth)/2,
            y: valueTextField.frame.maxY,
            width: CGFloat(TriangleWidth),
            height: CGFloat(TriangleWidth)
        )
        
        lazyUnitLab.frame = CGRect.init(x: valueTextField.frame.maxX + 10, y: valueTextField.frame.minY, width: 40, height: 40)
        
        self.addSubview(self.lazyUnitLab)
        self.addSubview(self.lazyCollectionView)
        self.addSubview(self.lazyTriangle)

        self.lazyCollectionView.frame = CGRect(
            x: 0,
            y: self.valueTextField.frame.maxY,
            width: self.bounds.size.width,
            height: CGFloat(CollectionHeight)
        )
        
        self.lazyUnitLab.text = tunit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var valueTextField: UITextField = {[unowned self] in
        let textField = UITextField()
        textField.textColor = .white
        textField.isUserInteractionEnabled = true
        textField.defaultTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "GothamRounded-Medium", size: 30)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        
        return textField
    }()

    lazy var lazyUnitLab: UILabel = {
        let zyUnitLab = UILabel()
        zyUnitLab.textColor = UIColor.red
        
        return zyUnitLab
    }()
    
    lazy var lazyCollectionView: UICollectionView = {[unowned self]in
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let zyCollectionView: UICollectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: CGFloat(CollectionHeight)),
            collectionViewLayout: flowLayout
        )
        
        zyCollectionView.backgroundColor = UIColor.clear
        zyCollectionView.bounces = true
        zyCollectionView.showsHorizontalScrollIndicator = false
        zyCollectionView.showsVerticalScrollIndicator = false
        zyCollectionView.delegate = self
        zyCollectionView.dataSource = self
        zyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "headCell")
        zyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "footerCell")
        zyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "customCell")

        return zyCollectionView
    }()
    
    lazy var lazyTriangle: TraingleView = {
        let triangleView = TraingleView()
        triangleView.backgroundColor = UIColor.clear
        triangleView.triangleColor = UIColor.red
        return triangleView
    }()
    
    @objc fileprivate func didChangeCollectionValue() {
        let textFieldValue = Float(valueTextField.text!)
        
        if (textFieldValue! - minValue)>=0 {
            self.setRealValueAndAnimated(realValue: (textFieldValue! - minValue) / step, animated: true)
        }
    }
    
    @objc fileprivate func setRealValueAndAnimated(realValue:Float,animated:Bool){
        fileRealValue = realValue
        let value = fileRealValue * step + minValue
        valueTextField.text = String(Int(value))
        lazyCollectionView.setContentOffset(CGPoint.init(x: Int(realValue)*RulerGap, y: 0), animated: animated)
    }
    
    func setDefaultValueAndAnimated(defaultValue: Float, animated:Bool) {
        fileRealValue = defaultValue
        valueTextField.text = String(Int(defaultValue))
        lazyCollectionView.setContentOffset(CGPoint.init(x: Int((defaultValue-minValue)/step) * RulerGap, y: 0), animated: animated)
    }
    
    @objc func editDone(){
        let currentText:NSString = valueTextField.text! as NSString
        if !self.judgeTextsHasWord(texts: currentText as String){
            alerts(vc: currentVC!, str: "请输入数字")
            return
        }
        valueTextField.resignFirstResponder()

        if currentText.floatValue > maxValue{
            valueTextField.text = String(Int(maxValue))
            self.perform(#selector(self.didChangeCollectionValue), with: nil, afterDelay: 0)
        }else if currentText.floatValue <= minValue || currentText.length == 0{
            valueTextField.text = String(Int(minValue))
            self.perform(#selector(self.didChangeCollectionValue), with: nil, afterDelay: 1)
        }else{
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.didChangeCollectionValue), with: nil, afterDelay: 1)
        }
        
    }
    
    func judgeTextsHasWord(texts:String) -> Bool{
        let scan:Scanner = Scanner.init(string: texts)
        var value:Float = 0.0
        return scan.scanFloat(&value) && scan.isAtEnd
    }
}

extension DYScrollRulerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2 + stepNum
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "headCell", for: indexPath)
            var headerView: DYHeaderRulerView? = cell.contentView.viewWithTag(1000) as? DYHeaderRulerView
            
            if headerView == nil {
                headerView = DYHeaderRulerView(frame: CGRect.init(x: 0, y: 0, width: Int(self.frame.size.width/2), height: CollectionHeight))
                headerView!.backgroundColor = UIColor.clear
                headerView!.headerMinValue = Int(minValue)
                headerView!.headerUnit = rulerUnit
                headerView!.tag = 1000
                cell.contentView.addSubview(headerView!)
            }
            return cell
            
        } else if indexPath.item == stepNum + 1 {
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "footerCell", for: indexPath)
            var footerView: DYFooterRulerView? = cell.contentView.viewWithTag(1001) as? DYFooterRulerView
            
            if footerView == nil {
                footerView = DYFooterRulerView.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.frame.size.width/2), height: CollectionHeight))
                footerView!.backgroundColor = UIColor.clear
                footerView!.footerMaxValue = Int(maxValue)
                footerView!.footerUnit = rulerUnit
                footerView!.tag   = 1001
                cell.contentView.addSubview(footerView!)
            }
            return cell
            
        } else{
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath)
            var rulerView: DYRulerView? = cell.contentView.viewWithTag(1002) as? DYRulerView
            
            if rulerView == nil {
                rulerView = DYRulerView(frame: CGRect(x: 0, y: 0, width: RulerGap * betweenNum, height: CollectionHeight))
                rulerView!.backgroundColor = UIColor.clear
                rulerView!.step = step
                rulerView!.unit = rulerUnit
                rulerView!.tag = 1002
                rulerView!.betweenNumber = betweenNum
                cell.contentView.addSubview(rulerView!)
            }
            
            rulerView!.minValue = step*Float((indexPath.item-1))*Float(betweenNum)+minValue
            rulerView!.maxValue = step*Float(indexPath.item)*Float(betweenNum)
            rulerView!.setNeedsDisplay()
 
            return cell
        }
        
    }
    
    
}
extension DYScrollRulerView:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = Int(scrollView.contentOffset.x)/RulerGap
        let totalValue = Float(value)*step+minValue
        
        if scrollByHand {
            if totalValue >= maxValue {
                valueTextField.text = String(Int(maxValue))
            } else if totalValue <= minValue {
                valueTextField.text = String(Int(minValue))
            } else{
                let value = Float(value) * step + minValue
                valueTextField.text = String(Int(value))
            }
        }
        
        delegate?.dyScrollRulerViewValueChange(rulerView: self, value: totalValue)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.setRealValueAndAnimated(realValue: Float(scrollView.contentOffset.x)/Float(RulerGap), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.setRealValueAndAnimated(realValue: Float(scrollView.contentOffset.x)/Float(RulerGap), animated: true)
    }
}
extension DYScrollRulerView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == stepNum + 1 {
            return CGSize(width: Int(self.frame.size.width / 2), height: CollectionHeight)
        }
        
        return CGSize(width: RulerGap * betweenNum, height: CollectionHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension DYScrollRulerView:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.editDone()
        return true
    }
    
}
