//
//  ViewController.swift
//  Timer
//
//  Created by 김원기 on 2022/08/24.
//

import UIKit

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    // 타이머에 설정되는 시간을 초로 저장하는 프로퍼티 선언
    // 데이트 피커의 시간을 초단위로 나누기 위해
    var duration = 60
    
    // timer status의 case를 갖는 파라미터 선언
    var timerStatus: TimerStatus = .end
    
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

    @IBAction func tapCancleButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause: // timerStatus가 시작이거나 일시정지 상태이면 취소버튼 활성화
            self.timerStatus = .end
            self.cancleButton.isEnabled = false
            self.datePicker.isHidden = false
            self.setTimerInfoViewVisble(isHidden: true)
            self.toggleButton.isSelected = false
            
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
            
            // self.timerLabel.isHidden = false
            // self.progressView.isHidden = false
            self.setTimerInfoViewVisble(isHidden: false)
            self.datePicker.isHidden = true
            
            self.toggleButton.isSelected = true
            self.cancleButton.isEnabled = true
            
        case .start:
            // 타이머 상태가 시작일 때 토글 버튼을 누르면 바뀌는 상황
            // 일시정지로 표기했기 때문에 다음 상황은 퍼즈를 해놓음
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            
        }
    }
    
}

