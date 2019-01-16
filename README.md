# MusicPlayerDemo
做了一个简单的音乐播放器. 

此播放器中使用的两种试验用素材分别来自手游《重装战姬》和动画《蔷薇少女》。

![image](https://github.com/Kimsswift/MusicPlayerDemo/blob/master/MusicPlay/e1.gif)

![image](https://github.com/Kimsswift/MusicPlayerDemo/blob/master/MusicPlay/e2.gif)

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
