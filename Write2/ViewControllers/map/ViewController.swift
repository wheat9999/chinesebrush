//
//  ViewController.swift
//  FF
//
//  Created by mac on 16/4/9.
//  Copyright © 2016年 duoying. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,BMKMapViewDelegate, BMKLocationServiceDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate{
    
    @IBOutlet weak var _mapView: BMKMapView!
    
    @IBOutlet weak var _btnDay: UIButton!
    
    @IBOutlet weak var _pickView: UIPickerView!
    
    @IBOutlet weak var _btnAccuracy: UIButton!
    
    @IBOutlet weak var _datePickView:UIDatePicker!
    
    @IBOutlet weak var _btnLocation:UIButton!
    
    var locationService: BMKLocationService!
    
    var locationCondition:Int!
    
    var annotationArray:Array<BMKPointAnnotation>!
    
    var disArray:Array<String>!
    
    var disDesArray:Array<String>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().applicationSupportsShakeToEdit = true;
        self.becomeFirstResponder()
        // Do any additional setup after loading the view, typically from a nib.
        locationService = BMKLocationService()
        locationService.allowsBackgroundLocationUpdates = true
        locationCondition = 0
        annotationArray = Array()
        disArray =    ["50","100","200","500","1000","2000","5000","10000","20000","50000","100000"]
        disDesArray = ["50米","100米","200米","500米","1公里","2公里","5公里","10公里","20公里","50公里","100公里"]
        _pickView.hidden = true
        _datePickView.hidden = true
        _btnLocation.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let acurayIndex = disArray.indexOf("\(Int(Env.sharedInstance._accuray!))")
        _btnAccuracy.setTitle(disDesArray[acurayIndex!], forState: UIControlState.Normal)
        _pickView.selectRow(acurayIndex!, inComponent: 0, animated: false)
        
        
        
        
        print("*********\(DateUtil.getCurrentTime())")
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationConditionComplete", name: "GPS-OK", object: nil);
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshToday", name: "LOC-NEW", object: nil);
        
        
                
        _btnDay.setTitle(Env.sharedInstance._curDate, forState: UIControlState.Normal);
        
        WebUtil.getDayRecord(Env.sharedInstance._curDate!, index: "0"){
            
            let recodesArray:Array<Record> = Util.parse($0);
            
            Env.sharedInstance.setTodayRecord(recodesArray)
            
            //有记录需要更新
            if recodesArray.count > 0 {
                self.refreshToday()
            }
            
            print("***********\r\n")
            print($0)
            self.locationConditionComplete()
            
        }
        
        
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return disArray.count;
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return disDesArray[row]
    }
    
    func locationConditionComplete()
    {
        locationCondition!++
        
        if locationCondition >= 1
        {
            self.locationBegin()
        }
    }
    
    @IBAction func dateChange()
    {
        print("date change");
        let changeDate = _datePickView.date
        let dateStr = DateUtil.getDateString(changeDate)
        _btnDay.setTitle(dateStr, forState: UIControlState.Normal)
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        _btnAccuracy.setTitle(disDesArray[row], forState: UIControlState.Normal);
        
        
    }
    
    func refreshRecord(records:Array<Record>)
    {
        if(records.count>0){
        _btnDay.setTitle(records[0].date, forState: UIControlState.Normal)
        }
        _mapView.removeAnnotations(_mapView.annotations)
        _mapView.removeOverlays(_mapView.overlays)
        annotationArray.removeAll();
        
        var coor:CLLocationCoordinate2D!
        for record in records {
            
            let annotion = BMKPointAnnotation()
            coor = CLLocationCoordinate2D(latitude: record.y!, longitude: record.x!)
            
            annotion.coordinate = coor
            annotion.title = record.time
            
            annotationArray.append(annotion)
        }
        
        if annotationArray.count > 0
        {
            _mapView.addAnnotations(annotationArray)
            
            
            let regin:BMKCoordinateRegion = BMKCoordinateRegionMake(coor,  BMKCoordinateSpanMake(0.01, 0.01));
            _mapView.setRegion(regin, animated: true)
        }
        
        if annotationArray.count > 1{
            
            let length = annotationArray.count
            var coors = [CLLocationCoordinate2D]()
            
            for item in records
            {
                let co  = CLLocationCoordinate2D(latitude: item.y!,longitude: item.x!)
                coors.append(co)
                
            }
            
            let polyline = BMKPolyline(coordinates: &coors, count: UInt(length))
            
            _mapView.addOverlay(polyline)
            
            
        }
    }
    
    func refreshToday()
    {
        print("alert refresh")
        
        if _btnDay.titleForState(UIControlState.Normal) == Env.sharedInstance._curDate {
        let records = Env.sharedInstance._records;
        self.refreshRecord(records!)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationService.delegate = self
        _mapView.delegate = self
        _mapView.zoomLevel = 16;
        _mapView.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationService.delegate = self
        _mapView.delegate = nil
        _mapView.viewWillDisappear()
    }
    
    // MARK: - IBAction
    
    func locationBegin()
    {
        print("进入普通定位态");
        locationService.startUserLocationService()
        _mapView.showsUserLocation = false//先关闭显示的定位图层
        _mapView.userTrackingMode = BMKUserTrackingModeFollow
        _mapView.showsUserLocation = true//显示定位图层
        
    }
    @IBAction func startLocationToday() {
        
        _btnDay.setTitle(Env.sharedInstance._curDate, forState: UIControlState.Normal);
        self.refreshToday()
        
       
    }
    
    @IBAction func preDay(){
        
        WebUtil.getDayRecord(_btnDay.titleForState(UIControlState.Normal)!, index: "-1"){
            
            let recodesArray:Array<Record> = Util.parse($0);
            
            //有记录需要更新
            if recodesArray.count > 0 {
                self.refreshRecord(recodesArray)
            }
            
        }
        
    }
    
    @IBAction func nextDay()
    {
        WebUtil.getDayRecord(_btnDay.titleForState(UIControlState.Normal)!, index: "1"){
            
            let recodesArray:Array<Record> = Util.parse($0);
            
            
            //有记录需要更新
            if recodesArray.count > 0 {
                self.refreshRecord(recodesArray)
            }
            
            
        }
    }
    
    @IBAction func setDic()
    {
          NSNotificationCenter.defaultCenter().postNotificationName("LOC-NEW", object: nil)
        _pickView.hidden = !_pickView.hidden
        
        if _pickView.hidden {
        
         let row =  _pickView.selectedRowInComponent(0)
         let disStr = disArray[row];
        Env.sharedInstance._accuray = (disStr as NSString).doubleValue
        }
        else
        {
            _datePickView.hidden = true
        }
        
        NSUserDefaults.standardUserDefaults().setValue(Env.sharedInstance._accuray, forKey: "accuray")
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    @IBAction func setDate()
    {
        _datePickView.hidden = !_datePickView.hidden
        
        if _datePickView.hidden == true{
            
            WebUtil.getDayRecord(_btnDay.titleForState(UIControlState.Normal)!, index: "1"){
                
                let recodesArray:Array<Record> = Util.parse($0);
                
                
                //有记录需要更新
                if recodesArray.count > 0 {
                    self.refreshRecord(recodesArray)
                }
                
                
            }
            
           

        }
        else
        {
             _pickView.hidden = true
        }
    }
    
    /**
     *在地图View将要启动定位时，会调用此函数
     *@param mapView 地图View
     */
    func willStartLocatingUser() {
        print("willStartLocatingUser");
    }
    
    /**
     *用户方向更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        print("heading is \(userLocation.heading)")
        _mapView.updateLocationData(userLocation)
    }
    
    /**
     *用户位置更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        print("didUpdateUserLocation lat:\(userLocation.location.coordinate.latitude) lon:\(userLocation.location.coordinate.longitude)")
        _mapView.updateLocationData(userLocation)
        
        //精度太差
        let accuracy = max(userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy);
        
        if (accuracy>100) {
            return;
        }
        
        let lon = String(format: "%03.4f", userLocation.location.coordinate.longitude)
        let lat = String(format: "%03.4f", userLocation.location.coordinate.latitude)
        
        let strTitle = "\(lon)\r\n\(lat)"
        _btnLocation.setTitle(strTitle, forState: UIControlState.Normal);
        
        Env.sharedInstance.addRecord(Record(_x: userLocation.location.coordinate.longitude,
            _y: userLocation.location.coordinate.latitude))
        
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        print("shake")
        let alert = UIAlertView.init(title: "提示", message: "输入终端号", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定","预览")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput;
        alert.show();
    }
    
    
    @IBAction func changeID()
    {
        let alert = UIAlertView.init(title: "提示", message: "输入终端号", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定","预览")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput;
        alert.show();
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex != alertView.cancelButtonIndex
        {
            let account =  alertView.textFieldAtIndex(0)?.text
            NSUserDefaults.standardUserDefaults().setValue(account, forKey: "account")
            Env.sharedInstance._account = account
        }
        
        if buttonIndex == 1
        {
            
            NSUserDefaults.standardUserDefaults().setValue("0", forKey: "read")
            NSUserDefaults.standardUserDefaults().synchronize();
            Env.sharedInstance._read = "0"
        }
        
        if buttonIndex == 2
        {
            NSUserDefaults.standardUserDefaults().setValue("1", forKey: "read")
            NSUserDefaults.standardUserDefaults().synchronize();
            Env.sharedInstance._read = "1"
        }
       
       
    }

    
    /**
     *在地图View停止定位后，会调用此函数
     *@param mapView 地图View
     */
    func didStopLocatingUser() {
        print("didStopLocatingUser")
    }


    /**
     *根据overlay生成对应的View
     *@param mapView 地图View
     *@param overlay 指定的overlay
     *@return 生成的覆盖物View
     */
    func mapView(mapView: BMKMapView!, viewForOverlay overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay as! BMKPolyline? != nil {
            let polylineView = BMKPolylineView(overlay: overlay as! BMKPolyline)
            polylineView.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
            polylineView.lineWidth = 2
            return polylineView
        }
        return nil
    }
    
    
    @IBAction func close()
    {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }



}

