//
//  ViewController.swift
//  movieApp
//
//  Created by 高田将弘 on 2020/06/17.
//  Copyright © 2020 高田将弘. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    }
    
    let fileOutput = AVCaptureMovieFileOutput()
    var recordButton: UIButton!
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 動画収録の画面
        setUpPreview()
    }
    
    func setUpPreview(){
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        
        do{
            if videoDevice == nil || audioDevice == nil {
                throw NSError(domain: "device error", code:-1, userInfo: nil) // エラーを出して、処理を終了する
            }

            let captureSession = AVCaptureSession()
            // video inputを capture sessionに追加
            let videoInput = try AVCaptureDeviceInput(device: videoDevice!)
            captureSession.addInput(videoInput)
            
            // audio inputを capture sessionに追加
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            captureSession.addInput(audioInput)
            
            // 録画時間の上限を設けたい時は maxRecordedDurationを設定する
            fileOutput.maxRecordedDuration = CMTimeMake(value: 30, timescale: 1)

            // video・audio両方の出力をsessionに追加
            captureSession.addOutput(fileOutput)
            
            // プレビュー
            let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.frame = self.view.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.addSublayer(videoLayer)
            
            captureSession.startRunning()
            
            setUpButton() // 収録開始ボタンを配置する
        } catch{
            // エラー処理
        }
    }
    
    func setUpButton(){
        recordButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50)) // 配置する場所の指定
        recordButton.backgroundColor = UIColor.gray
        recordButton.layer.masksToBounds = true
        recordButton.setTitle("録画開始", for: UIControl.State.normal)
        recordButton.layer.cornerRadius = 20.0
        recordButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height-50)
        recordButton.addTarget(self, action: #selector(ViewController.onClickRecordButton(sender:)), for: .touchUpInside) // ボタンをタップした時、指定したメソッドを呼び出す

        self.view.addSubview(recordButton)
    }
    
    @objc func onClickRecordButton(sender: UIButton) { // 収録開始ボタンタップ時に呼び出されるメソッド
        if !isRecording {
               // 録画開始
               let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
               let documentsDirectory = paths[0] as String
               let filePath : String? = "\(documentsDirectory)/temp.mp4"
               let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
               fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)

               isRecording = true
               changeButtonColor(target: recordButton, color: UIColor.red)
               recordButton.setTitle("録画中", for: .normal)
           } else {
               // 録画終了
               fileOutput.stopRecording()

               isRecording = false
               changeButtonColor(target: recordButton, color: UIColor.gray)
               recordButton.setTitle("録画開始", for: .normal)
           }
    }
    
    func changeButtonColor(target: UIButton, color: UIColor) { // ボタンが押される度、プロパティを変更する為、このメソッドを用意している
        target.backgroundColor = color
    }
}
