//
//  ViewController.swift
//  MusicPlay
//
//  Created by J K on 2019/1/15.
//  Copyright © 2019 Kims. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, CAAnimationDelegate {

    var viewOfImage: ViewOfImage? //专辑封面所在视图
    private var progressBarView: ProgressBarView? //进度条所在视图
    
    public var audioPlayer: AVAudioPlayer! //音频播放
    private var playBtn: UIButton! //播放按钮
    private var isClick: Bool = false //判断按钮是否被点击
    
    private let musics = ["重装战姬", "ALI PROJECT-薔薇の呪縛"] //歌曲集
    private let albumImg = ["role2-0", "BaraGirl3"] //专辑封面名
    private var musicNum: Int = 0 //歌曲索引值
    
    private var nameLabel: UILabel! //歌名
    private var totalTimeLabel: UILabel! //歌曲总时间长
    var currentTimeLabel: UILabel! //歌曲当前播放时间戳
    
    private var anima: CAKeyframeAnimation! //专辑封面动画
    
    private var t: CFTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = #colorLiteral(red: 1, green: 0.6881448195, blue: 0.6278065961, alpha: 1)
        
        //专辑封面配置
        viewOfImage = ViewOfImage(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        viewOfImage!.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 140)
        viewOfImage!.layer.cornerRadius = 100
        self.view.addSubview(viewOfImage!)
        
        //进度条配置
        progressBarView = ProgressBarView(frame: CGRect(x: 0, y: 0, width: 320, height: 5))
        progressBarView!.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 170)
        self.view.addSubview(progressBarView!)
        progressBarView!.vieww = self
        
        //歌词标签
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        nameLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.origin.y + 60)
        nameLabel.text = musics[0]
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = UIColor.white
        self.view.addSubview(nameLabel)
        
        //播放按钮配置
        playBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        playBtn.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 100)
        playBtn.layer.cornerRadius = 30
        playBtn.layer.borderWidth = 3
        playBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.9560945337, blue: 0.7634074533, alpha: 1)
        playBtn.setTitle("P", for: .normal)
        playBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        playBtn.setTitleColor(#colorLiteral(red: 1, green: 0.9560945337, blue: 0.7634074533, alpha: 1), for: .normal)
        playBtn.addTarget(self, action: #selector(ViewController.playButton), for: .touchUpInside)
        self.view.addSubview(playBtn)
        
        //下一首按钮配置
        let nextBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        nextBtn.center = CGPoint(x: self.view.center.x + 90, y: self.view.frame.height - 80)
        nextBtn.layer.cornerRadius = 25
        nextBtn.layer.borderWidth = 2
        nextBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.9560945337, blue: 0.7634074533, alpha: 1)
        nextBtn.setTitle(">", for: .normal)
        nextBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 23)
        nextBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        nextBtn.addTarget(self, action: #selector(ViewController.nextButton), for: .touchUpInside)
        self.view.addSubview(nextBtn)
        
        //上一首按钮配置
        let prevBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        prevBtn.center = CGPoint(x: self.view.center.x - 90, y: self.view.frame.height - 80)
        prevBtn.layer.cornerRadius = 25
        prevBtn.layer.borderWidth = 2
        prevBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.9560945337, blue: 0.7634074533, alpha: 1)
        prevBtn.setTitle("<", for: .normal)
        prevBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 23)
        prevBtn.setTitleColor(#colorLiteral(red: 1, green: 0.9560945337, blue: 0.7634074533, alpha: 1), for: .normal)
        prevBtn.addTarget(self, action: #selector(ViewController.prevButton), for: .touchUpInside)
        self.view.addSubview(prevBtn)
        
        //配置音频
        musicColle(i: musicNum)
        
        //配置歌曲总时长
        totalTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
        totalTimeLabel.center = CGPoint(x: self.view.center.x + 150, y: self.view.frame.size.height - 150)
        if Int(audioPlayer.duration) < 60 {
            totalTimeLabel.text = "00:\(Int(audioPlayer.duration))"
        }else {
            let m = Int(audioPlayer.duration) / 60
            let s = Int(audioPlayer.duration) % 60
            if s == 0 {
                totalTimeLabel.text = "\(m):00"
            }else if s > 0 && s < 10 {
                totalTimeLabel.text = "\(m):0\(s)"
            }else if s >= 10 {
                totalTimeLabel.text = "\(m):\(s)"
            }
        }
        totalTimeLabel.textAlignment = NSTextAlignment.center
        totalTimeLabel.font = UIFont.boldSystemFont(ofSize: 15)
        totalTimeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.view.addSubview(totalTimeLabel)
        
        //配置当前播放时间戳
        currentTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
        currentTimeLabel.center = CGPoint(x: self.view.center.x - 150, y: self.view.frame.size.height - 150)
        currentTimeLabel.text = "00:00"
        currentTimeLabel.textAlignment = NSTextAlignment.center
        currentTimeLabel.font = UIFont.boldSystemFont(ofSize: 15)
        currentTimeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.view.addSubview(currentTimeLabel)
        
        //配置动画
        anima = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        anima.values = [0, 3.14*2]
        anima.duration = 5
        anima.timingFunctions = [CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)]
        anima.repeatCount = MAXFLOAT
        anima.calculationMode = .cubicPaced
        anima.delegate = self
        viewOfImage!.layer.add(anima, forKey: "animation")
        
        //动画的暂停
        let pauseTime = CACurrentMediaTime()
        viewOfImage!.layer.timeOffset = pauseTime
        viewOfImage!.layer.speed = 0
    }
    
    //配置音频，支持背景播放
    func musicColle(i: Int) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            //仅支持ios 11.0 以上设备
            if #available(iOS 11.0, *) {
                //可进行背景播放
                try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth, .defaultToSpeaker])
            }else {
                return
            }
            //支持远程控制
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            //歌曲路径
            let path = Bundle.main.path(forResource: musics[i], ofType: "mp3")
            let url = URL(fileURLWithPath: path!)
            
            try audioPlayer = AVAudioPlayer(contentsOf: url as URL)
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = 0
            audioPlayer.pan = 0.0
            audioPlayer.volume = 1.0
            audioPlayer.delegate = self
        }catch {
            print(error)
        }
    }
    
    //音频结束时调用
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if musicNum + 1 < musics.count {
            musicNum += 1
            
            //更换封面和歌名
            viewOfImage!.imageViews.image = UIImage(named: albumImg[musicNum])
            nameLabel.text = musics[musicNum]
            
            musicColle(i: musicNum)
            //播放音乐
            audioPlayer.play()
            
            //根据歌曲总时长改变标签
            if Int(audioPlayer.duration) < 60 {
                totalTimeLabel.text = "00:\(Int(audioPlayer.duration))"
            }else {
                let m = Int(audioPlayer.duration) / 60
                let s = Int(audioPlayer.duration) % 60
                if s == 0 {
                    totalTimeLabel.text = "\(m):00"
                }else if s > 0 && s < 10 {
                    totalTimeLabel.text = "\(m):0\(s)"
                }else if s >= 10 {
                    totalTimeLabel.text = "\(m):\(s)"
                }
            }
        }else {
            progressBarView!.display.isPaused = true
            playBtn.setTitle("P", for: .normal)
            isClick = false
            print("整个库里的音乐播放完毕")
            return
        }
    }
    
    //播放按钮
    @objc func playButton() {
        if isClick == true {
            progressBarView!.display.isPaused = true //暂停计时器
            playBtn.setTitle("P", for: .normal)
            audioPlayer.pause() //暂停播放音频
            isClick = false
            
            //暂停封面的旋转
            let pauseTime = CACurrentMediaTime()
            viewOfImage!.layer.timeOffset = pauseTime
            viewOfImage!.layer.speed = 0
        }else {
            progressBarView!.display.isPaused = false //继续执行计时器
            playBtn.setTitle("||", for: .normal)
            audioPlayer.play() //开始播放音频
            isClick = true
            
            //继续进行封面的旋转动画
            let pauseTime = viewOfImage!.layer.timeOffset
            let t = CACurrentMediaTime() - pauseTime
            viewOfImage!.layer.timeOffset = 0
            viewOfImage!.layer.beginTime = t
            viewOfImage!.layer.speed = 1
           
        }
    }
    
    //下一首
    @objc func nextButton() {
        if musicNum + 1 < musics.count {
            musicNum += 1
            
            //更换封面和歌名
            viewOfImage!.imageViews.image = UIImage(named: albumImg[musicNum])
            nameLabel.text = musics[musicNum]
            
            musicColle(i: musicNum)
            
            if isClick == true {
                playBtn.setTitle("||", for: .normal)
                audioPlayer.play()
            }else {
                playBtn.setTitle("P", for: .normal)
                audioPlayer.pause()
            }
            
            //根据歌曲总时长改变标签
            if Int(audioPlayer.duration) < 60 {
                totalTimeLabel.text = "00:\(Int(audioPlayer.duration))"
            }else {
                let m = Int(audioPlayer.duration) / 60
                let s = Int(audioPlayer.duration) % 60
                if s == 0 {
                    totalTimeLabel.text = "\(m):00"
                }else if s > 0 && s < 10 {
                    totalTimeLabel.text = "\(m):0\(s)"
                }else if s >= 10 {
                    totalTimeLabel.text = "\(m):\(s)"
                }
            }
        }else {
            print("没有下一首啦~")
        }
    }
    
    //上一首
    @objc func prevButton() {
        if musicNum - 1 >= 0 {
            musicNum -= 1
            
            //更换封面和歌名
            viewOfImage!.imageViews.image = UIImage(named: albumImg[musicNum])
            nameLabel.text = musics[musicNum]
            
            musicColle(i: musicNum)
            
            if isClick == true {
                playBtn.setTitle("||", for: .normal)
                audioPlayer.play()
            }else {
                playBtn.setTitle("P", for: .normal)
                audioPlayer.pause()
            }
            
            //根据歌曲总时长改变标签
            if Int(audioPlayer.duration) < 60 {
                totalTimeLabel.text = "00:\(Int(audioPlayer.duration))"
            }else {
                let m = Int(audioPlayer.duration) / 60
                let s = Int(audioPlayer.duration) % 60
                if s == 0 {
                    totalTimeLabel.text = "\(m):00"
                }else if s > 0 && s < 10 {
                    totalTimeLabel.text = "\(m):0\(s)"
                }else if s >= 10 {
                    totalTimeLabel.text = "\(m):\(s)"
                }
            }
        }else {
            print("上一首没歌哦")
        }
    }
}

