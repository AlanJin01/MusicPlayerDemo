# MusicPlayerDemo
做了一个简单的音乐播放器. 

此播放器中使用的两种试验用素材分别来自手游《重装战姬》和动画《蔷薇少女》。

![image](https://github.com/Kimsswift/MusicPlayerDemo/blob/master/MusicPlay/e1.gif)

![image](https://github.com/Kimsswift/MusicPlayerDemo/blob/master/MusicPlay/e2.gif)

下面是配置音频，如支持背景播放、创建歌曲路径等

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

下面是利用CADisplayLink来创建计时器，以便实时更新歌曲播放进度

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

下面是歌曲结束时自动切换下一首，并同时能够切换专辑封面和歌名

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
