//
//  ViewController.swift
//  Timer
//
//  Created by 김원기 on 2022/08/24.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    // 타이머에 설정되는 시간을 초로 저장하는 프로퍼티 선언
    // 데이트 피커의 시간을 초단위로 나누기 위해
    var duration = 60
    
    // timer status의 case를 갖는 파라미터 선언
    var timerStatus: TimerStatus = .end
    
    //
    var timer: DispatchSourceTimer?
    
    // 현재 카운트다운 되고 있는 시간을 초로 저장하는 프로퍼티
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }
    
    // 각각의 라벨과 뷰의 isHidden 값을 바꾸기 위한 함수
    func setTimerInfoViewVisble(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    // 시작 버튼이 눌렸을 때 시작 버튼을 일시 정지 버튼으로 변경하는 함수
    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        // 초기 즉 선택되지 않은 상태에서는 노말상태, 선택된 상태에서는 일시정지로 타이틀을 변경한다.
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    // 메소드 안에서 타이머를 설정하고 시작하도록 구현
    func startTimer() {
        if self.timer == nil {
            // flags 파라미터에는 빈, queue 파라미터는 어떤 스레드 큐에서 반복동작 할지 선언
            // 타이머가 돌때마다 UI에 작업하기 때문에 main Thread에서 작동한다
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1) // 1초마다 반복
            self.timer?.setEventHandler(handler: { [weak self] in
                // 타이머 설정 시간을 시:분:초로 변환
                guard let self = self else { return }
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                
                // progressView를 점점 줄어들게 표시
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                // UIImageView의 애니메이션 설정
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                })
                
                if self.currentSeconds <= 0 {
                    // 타이머 종료
                    self.stopTimer()
                    // 타이머 종료시 알람이 울리도록 하는 코드이며 AutioToolBox 를 import한다.
                    // ID값은 iphonedev.wiki에 있는 사운드 id를 참고
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    // 메소드 안에서 타이머를 취소하도록 구현
    func stopTimer() {
        
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        self.timerStatus = .end
        // UIView.animate 활용을 위해 isHidden은 삭제
        // self.cancleButton.isEnabled = false
        // self.datePicker.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        })
        self.setTimerInfoViewVisble(isHidden: true)
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        
        // 타이머를 종료할때는 꼭 nil을 선언하여 종료하여야 한다 아니면 타이머가 계속 동작될 수 있다.
        self.timer = nil
        
       
    }

    @IBAction func tapCancleButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause: // timerStatus가 시작이거나 일시정지 상태이면 취소버튼 활성화
            
            self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        
        // 시작버튼을 누르면 데이터 피커가 사라지고 남은 시간을 표시하는 라벨과 감소하는 프로그레스 뷰를 표시되고
        // 취소 버튼을 활성화 하면 시작 버튼을 일시 정지로 바꾸는것
        switch self.timerStatus {
        case .end:
            self.timerStatus = .start
            self.currentSeconds = self.duration
            
            // self.timerLabel.isHidden = false
            // self.progressView.isHidden = false
            // 단순한 isHidden은 아래와 같이 함수 호출로 가능
            // UIViewAnimation을 활용하기 위해 알파값 설정후 코드 작성
            // self.setTimerInfoViewVisble(isHidden: false)
            // self.datePicker.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.toggleButton.isSelected = true
            self.cancleButton.isEnabled = true
            self.startTimer()
            
        case .start:
            // 타이머 상태가 시작일 때 토글 버튼을 누르면 바뀌는 상황
            // 일시정지로 표기했기 때문에 다음 상황은 퍼즈를 해놓음
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
            
        }
    }
    
}

