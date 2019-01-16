//
//  ProgressBarView.swift
//  MusicPlay
//
//  Created by J K on 2019/1/15.
//  Copyright © 2019 Kims. All rights reserved.
//

import UIKit

class ProgressBarView: UIView {

    private var ball: UIView! //进度条中可移动的球
    private var frontView: UIView!
    
    var display: CADisplayLink! //计时器
    private var percentOfPlay: Double!
    
    private var m: Int = 0 //分(当前播放)
    private var s: Int = 0 //秒(当前播放)
    
    weak var vieww: ViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        frontView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: frame.height))
        frontView.backgroundColor = #colorLiteral(red: 0.550810667, green: 1, blue: 0.4890547406, alpha: 1)
        self.addSubview(frontView)
        
        ball = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ball.center = CGPoint(x: 0, y: self.center.y)
        ball.layer.cornerRadius = 10
        ball.backgroundColor = #colorLiteral(red: 0.3780416712, green: 0.5944330661, blue: 1, alpha: 1)
        ball.layer.shadowColor = UIColor.black.cgColor
        ball.layer.shadowOffset = CGSize(width: 2, height: 2)
        ball.layer.shadowOpacity = 0.3
        ball.layer.shadowRadius = 2
        ball.clipsToBounds = false
        ball.isUserInteractionEnabled = true
        self.addSubview(ball)
        
        //配置同步屏幕刷新频率计时器
        display = CADisplayLink(target: self, selector: #selector(ProgressBarView.musicPlay))
        display.add(to: RunLoop.current, forMode: .common)
    }
    
    //计时器调用的方法
    @objc func musicPlay() {
        percentOfPlay = vieww!.audioPlayer.currentTime / vieww!.audioPlayer.duration
        ball.center.x = self.frame.size.width * CGFloat(percentOfPlay)
        frontView.frame.size.width = ball.center.x
        
        //更新当前播放时间
        if Int(vieww!.audioPlayer.currentTime) < 60 {
            s = Int(vieww!.audioPlayer.currentTime)
            if s < 10 {
                vieww!.currentTimeLabel.text = "00:0\(s)"
            }else {
                vieww!.currentTimeLabel.text = "00:\(s)"
            }
        }else {
            m = Int(vieww!.audioPlayer.currentTime) / 60
            s = Int(vieww!.audioPlayer.currentTime) % 60
            if s < 10 {
                vieww!.currentTimeLabel.text = "\(m):0\(s)"
            }else {
                vieww!.currentTimeLabel.text = "\(m):\(s)"
            }
        }
    }
    
    //进度条移动
    private func barOffset(_ n: CGFloat) {
        ball.center.x += n
        frontView.frame.size.width = ball.center.x
    }
    
    //用户移动进度条
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        let loc = touch?.location(in: self)
        let preLoc = touch?.previousLocation(in: self)
        let offset = loc!.x - preLoc!.x
        
        let n = offset + ball.center.x
        
        if touch?.view == self.ball && n < 0 {
            return
        }else if touch?.view == self.ball && n > self.frame.width {
            return
        }
        
        if touch?.view == self.ball && n >= 0 && n <= self.frame.width {
            barOffset(offset)
        }
    }
    
    //用户停止移动进度条时调歌曲进度
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let n = ball.center.x / self.frame.size.width
        vieww!.audioPlayer.currentTime = vieww!.audioPlayer.duration * Double(n)
        display.isPaused = false
    }
    
    //用户开始点击ball视图时，暂停display计时器
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == ball {
            display.isPaused = true
        }
    }
    
    //释放
    deinit {
        display.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
