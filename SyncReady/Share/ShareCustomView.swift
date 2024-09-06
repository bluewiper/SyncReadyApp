//
//  ShareCustomView.swift
//  Share
//
//  Created by 단예진 on 9/1/24.
//

import UIKit
import SnapKit


class ShareCustomView: UIView {
    
    private let shareLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "AI 일정 생성을 위해 크롭된\n스크린샷을 업로드해주세요"
        return label
    }()
    
    let shareImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red // 디버깅용
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    lazy var generateScheduleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("일정 생성", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(generateScheduleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(shareLabel)
        addSubview(shareImageView)
        addSubview(generateScheduleButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        // '사용 가이드' 라벨 제약조건
        shareLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }
        // '사용자 사진 로드' 이미지뷰 제약조건
        shareImageView.snp.makeConstraints {
            $0.top.equalTo(shareLabel.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(434)
        }
        // '일정 생성' 버튼 제약조건
        generateScheduleButton.snp.makeConstraints {
            $0.top.equalTo(shareImageView.snp.bottom).offset(58)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.width.equalTo(160)
        }
    }
    
    @objc func generateScheduleButtonTapped() {
        // 버튼 탭 시 OCR 작동 > AI 작동 > 일정 뷰 생성 > 리스트 캘린더 저장
        print("일정 생성 버튼이 눌렸습니다.")
    }
}
