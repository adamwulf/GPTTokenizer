//
//  GPTTokenizerTests.swift
//  
//
//  Created by Adam Wulf on 5/12/23.
//

import XCTest
@testable import GPTTokenizer

final class GPTTokenizerTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(try GPTTokenizer.Encode("hello world").count, 2)
        XCTAssertEqual(try GPTTokenizer.Encode("hello world"), [15339, 1917])
    }

    func testLarge() throws {
        let str = """
<?xml version="1.0" encoding="UTF-8"?>
<nib>
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="16087"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <objects>
        <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner" customClass="FeedbackViewController">
            <connections>
                <outlet property="debugLogsSwitch" destination="zJg-0L-6fK" id="J5J-9z-4f6"/>
                <outlet property="emailTextField" destination="v6y-6z-5Jx" id="J5J-9z-4f5"/>
                <outlet property="feedbackTextView" destination="XZB-7f-5a5" id="J5J-9z-4f4"/>
            </connections>
        </placeholder>
        <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder"/>
        <viewController id="yKz-9a-3JN" customClass="FeedbackViewController" customModule="ModuleName" customModuleProvider="target" sceneMemberID="viewController">
            <view key="view" contentMode="scaleToFill" id="d0H-3f-vdC">
                <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
                <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                <subviews>
                    <textView clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToFill" text="Feedback" textAlignment="natural" translatesAutoresizingMaskIntoConstraints="NO" id="XZB-7f-5a5">
                        <rect key="frame" x="20" y="20" width="335" height="150"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                        <fontDescription key="fontDescription" type="system" pointSize="17"/>
                        <textInputTraits key="textInputTraits"/>
                    </textView>
                    <textField clipsSubviews="YES" contentMode="scaleToFill" text="Email" textAlignment="natural" translatesAutoresizingMaskIntoConstraints="NO" id="v6y-6z-5Jx">
                        <rect key="frame" x="20" y="190" width="335" height="30"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                        <fontDescription key="fontDescription" type="system" pointSize="17"/>
                        <textInputTraits key="textInputTraits" keyboardType="emailAddress"/>
                    </textField>
                    <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Include Debug Logs" textAlignment="natural" lineBreakMode="tailTruncation" numberOfLines="1" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="J5J-9z-4f8">
                        <rect key="frame" x="20" y="230" width="150" height="21"/>
                        <fontDescription key="fontDescription" type="system" pointSize="17"/>
                        <color key="textColor" systemColor="labelColor" cocoaTouchSystemColor="darkTextColor"/>
                        <nil key="highlightedColor"/>
                    </label>
                    <switch contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="zJg-0L-6fK">
                        <rect key="frame" x="295" y="225" width="51" height="31"/>
                        <color key="thumbTintColor" systemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                        <color key="onTintColor" systemColor="systemBlueColor" cocoaTouchSystemColor="blueColor"/>
                        <color key="tintColor" systemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                    </switch>
                    <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="roundedRect" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="J5J-9z-4f9">
                        <rect key="frame" x="20" y="270" width="335" height="30"/>
                        <color key="backgroundColor" systemColor="systemBlueColor" cocoaTouchSystemColor="blueColor"/>
                        <constraints>
                            <constraint firstAttribute="height" constant="30" id="J5J-9z-4f9.height"/>
                        </constraints>
                        <state key="normal" title="Submit">
                            <color key="titleColor" systemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                        </state>
                        <connections>
                            <action selector="submitButtonTapped:" destination="-1" eventType="touchUpInside" id="J5J-9z-4f9"/>
                        </connections>
                    </button>
                </subviews>
                <color key="backgroundColor" systemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                <viewLayoutGuide key="safeArea" id="yfC-2t-3ea"/>
            </view>
            <navigationItem key="navigationItem" id="J5J-9z-4f7"/>
            <connections>
                <outlet property="debugLogsSwitch" destination="zJg-0L-6fK" id="J5J-9z-4f6"/>
                <outlet property="emailTextField" destination="v6y-6z-5Jx" id="J5J-9z-4f5"/>
                <outlet property="feedbackTextView" destination="XZB-7f-5a5" id="J5J-9z-4f4"/>
            </connections>
        </viewController>
    </objects>
    <resources>
        <systemColor name="labelColor">
            <color red="0.0" green="0.0" blue="0.0" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
        </systemColor>
        <systemColor name="systemBackgroundColor">
            <color red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
        </systemColor>
        <systemColor name="systemBlueColor">
            <color red="0" green="0.47843137254901963" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
        </systemColor>
    </resources>
</nib>
"""
        print("count: \(try GPTTokenizer.Encode(str).count)")
    }
}
