import { router, promptAction } from '@kit.ArkUI';
import {
  connectHealthDevice,
  deviceStatus,
  getElderHealthAlerts,
  getElderHealthMetrics,
  getWatchedElderId,
  HealthMetric,
  healthAlerts,
  healthMetrics
} from '../models/AppData';

@Entry
@Component
struct HealthMetricPage {
  @State heartRate: string = '76';
  @State bloodPressure: string = '130/85';
  @State bloodSugar: string = '6.2';
  @State refreshToken: number = 0;

  private saveHeartRate(): void {
    const rate: number = Number(this.heartRate);
    const isNormal: boolean = rate >= 50 && rate <= 110;
    healthMetrics.unshift({
      elderId: getWatchedElderId(),
      type: 'heartRate',
      name: '心率',
      value: this.heartRate + ' 次/分',
      numericValue: rate,
      unit: '次/分',
      time: '刚刚',
      normal: isNormal
    });
    if (!isNormal) {
      healthAlerts.unshift({
        elderId: getWatchedElderId(),
        type: 'heartRate',
        title: rate > 110 ? '心率偏高' : '心率偏低',
        value: this.heartRate + ' 次/分',
        time: '刚刚',
        notified: true
      });
      promptAction.showToast({ message: '心率异常，已提醒监护人' });
    } else {
      promptAction.showToast({ message: '心率记录已保存' });
    }
    this.refreshToken++;
  }

  private saveRoutineMetric(): void {
    healthMetrics.unshift({
      elderId: getWatchedElderId(),
      type: 'bloodPressure',
      name: '血压',
      value: this.bloodPressure + ' mmHg',
      numericValue: 0,
      unit: 'mmHg',
      time: '刚刚',
      normal: true
    });
    healthMetrics.unshift({
      elderId: getWatchedElderId(),
      type: 'bloodSugar',
      name: '血糖',
      value: this.bloodSugar + ' mmol/L',
      numericValue: Number(this.bloodSugar),
      unit: 'mmol/L',
      time: '刚刚',
      normal: true
    });
    this.refreshToken++;
    promptAction.showToast({ message: '健康指标已保存' });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('健康监测')
        this.DeviceConnectCard()
        this.AlertCard()
        this.SectionTitle('最近指标')
        ForEach(getElderHealthMetrics(), (item: HealthMetric) => {
          this.MetricRow(item)
        }, (item: HealthMetric) => item.name + item.time + item.value + this.refreshToken.toString())
        this.HeartRateCard()
        this.RoutineMetricCard()
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder DeviceConnectCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 5 }) {
          Text(deviceStatus.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text(deviceStatus.connected ? '已连接，' + deviceStatus.lastSync : '未连接，请打开手环并靠近手机')
            .fontSize(16)
            .lineHeight(23)
            .fontColor('#52635F')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(deviceStatus.battery.toString() + '%')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0B7A5B')
      }
      .width('100%')
      Button(deviceStatus.connected ? '重新同步心率' : '搜索并连接手环')
        .width('100%')
        .height(52)
        .fontSize(19)
        .borderRadius(20)
        .backgroundColor('#0B7A5B')
        .onClick(() => {
          connectHealthDevice();
          this.refreshToken++;
          promptAction.showToast({ message: '手环已连接，并同步一条心率记录' });
        })
      Text('请打开手环并靠近手机，连接后会同步最近健康记录。')
        .fontSize(14)
        .lineHeight(21)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder HeartRateCard() {
    Column({ space: 12 }) {
      Text('手动记录心率')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('低于 50 或高于 110 次/分钟会触发异常提醒。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#52635F')
      TextInput({ text: this.heartRate, placeholder: '例如 76' })
        .height(50)
        .fontSize(18)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.heartRate = value;
        })
      Button('保存心率')
        .width('100%')
        .height(50)
        .fontSize(18)
        .borderRadius(18)
        .backgroundColor('#0B7A5B')
        .onClick(() => this.saveHeartRate())
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RoutineMetricCard() {
    Column({ space: 12 }) {
      Text('血压与血糖')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      TextInput({ text: this.bloodPressure, placeholder: '血压，例如 130/85' })
        .height(50)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.bloodPressure = value;
        })
      TextInput({ text: this.bloodSugar, placeholder: '血糖，例如 6.2' })
        .height(50)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.bloodSugar = value;
        })
      Button('保存血压血糖')
        .width('100%')
        .height(50)
        .fontSize(18)
        .borderRadius(18)
        .fontColor('#0B7A5B')
        .backgroundColor('#E7F5EF')
        .onClick(() => this.saveRoutineMetric())
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder AlertCard() {
    Column({ space: 12 }) {
      Row() {
        Text(getElderHealthAlerts().length > 0 ? '需要关注' : '状态平稳')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(getElderHealthAlerts().length > 0 ? '#B42318' : '#0B7A5B')
        Blank()
        Text(getElderHealthAlerts().length > 0 ? '已通知家属' : '正常')
          .fontSize(14)
          .fontColor(getElderHealthAlerts().length > 0 ? '#B42318' : '#0B7A5B')
      }
      .width('100%')
      Text(getElderHealthAlerts().length > 0 ? getElderHealthAlerts()[0].title + '：' + getElderHealthAlerts()[0].value + '。建议先坐下休息，几分钟后复测一次。' : '当前没有异常生命体征，继续保持定期记录。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Row({ space: 10 }) {
        Button('复测一次')
          .layoutWeight(1)
          .height(46)
          .fontSize(17)
          .borderRadius(16)
          .backgroundColor('#0B7A5B')
          .onClick(() => promptAction.showToast({ message: '请休息后重新记录心率' }))
        Button('联系家属')
          .layoutWeight(1)
          .height(46)
          .fontSize(17)
          .borderRadius(16)
          .fontColor('#B42318')
          .backgroundColor('#FFFFFF')
          .onClick(() => router.pushUrl({ url: 'pages/FamilyAssistPage' }))
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(getElderHealthAlerts().length > 0 ? '#FFF1F0' : '#E7F5EF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder MetricRow(item: HealthMetric) {
    Column({ space: 8 }) {
      Row() {
        Text(item.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text(item.normal ? '正常' : '异常')
          .fontSize(14)
          .fontColor(item.normal ? '#0B7A5B' : '#B42318')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(14)
          .backgroundColor(item.normal ? '#E7F5EF' : '#FFF1F0')
      }
      .width('100%')
      Row() {
        Text(item.time)
          .fontSize(14)
          .fontColor('#667085')
          .layoutWeight(1)
        Text(item.value)
          .fontSize(item.type === 'bloodPressure' ? 15 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.normal ? '#0B7A5B' : '#B42318')
          .maxLines(1)
          .textAlign(TextAlign.End)
          .width(118)
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(item.normal ? '#FFFFFF' : '#FFF1F0')
  }

  @Builder SectionTitle(title: string) {
    Text(title)
      .fontSize(22)
      .fontWeight(FontWeight.Bold)
      .fontColor('#14213D')
      .width('100%')
  }

  @Builder Header(title: string) {
    Row() {
      Text(title)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#102A27')
      Blank()
      Button('返回')
        .height(40)
        .borderRadius(16)
        .fontColor('#0B7A5B')
        .backgroundColor('#FFFFFF')
        .onClick(() => router.back())
    }
    .width('100%')
  }
}
