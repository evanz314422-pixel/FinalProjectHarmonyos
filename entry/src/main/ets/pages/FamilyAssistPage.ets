import { router, promptAction } from '@kit.ArkUI';
import { currentSession, getCurrentElder, getElderHealthAlerts, getElderTodayRecords, MedicationRecord } from '../models/AppData';

@Entry
@Component
struct FamilyAssistPage {
  @State missedNotify: boolean = true;
  @State healthNotify: boolean = true;
  @State stockNotify: boolean = true;
  @State dailySummary: boolean = false;
  @State bindCode: string = '';
  @State bindSuccess: boolean = true;

  private bindElder(): void {
    if (this.bindCode === getCurrentElder().bindCode) {
      this.bindSuccess = true;
      promptAction.showToast({ message: '已绑定' + getCurrentElder().name });
    } else {
      this.bindSuccess = false;
      promptAction.showToast({ message: '绑定码不正确，请核对老人端显示的号码' });
    }
  }

  private nextRecord(): MedicationRecord {
    const records: MedicationRecord[] = getElderTodayRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status === '待服用') {
        return records[index];
      }
    }
    return records.length > 0 ? records[0] : {
      elderId: getCurrentElder().id,
      time: '今天',
      medicineName: '用药任务',
      status: '待确认',
      source: '系统未响应'
    };
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header(currentSession.role === 'guardian' ? '绑定与通知' : '家属协助')
        if (currentSession.role === 'guardian') {
          this.GuardianBindCard()
        } else {
          this.ElderBindCard()
        }
        this.PermissionCard()
        this.NotifyCard()
        this.NotificationFlowCard()
        this.AlertCard()
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder ElderBindCard() {
    Column({ space: 12 }) {
      Text('我的绑定码')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('请在“我的”页面查看绑定码')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0B7A5B')
      Text('把这个号码告诉家属，家属就可以在监护人端查看服药记录、库存和心率异常。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Text('已绑定：' + getCurrentElder().contact)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder GuardianBindCard() {
    Column({ space: 12 }) {
      Text('绑定老人账号')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('输入老人端“我的”页面显示的绑定码。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      TextInput({ text: this.bindCode, placeholder: '请输入绑定码' })
        .height(50)
        .fontSize(18)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.bindCode = value;
        })
      Button(this.bindSuccess ? '已绑定' + getCurrentElder().name : '确认绑定')
        .width('100%')
        .height(52)
        .fontSize(19)
        .borderRadius(20)
        .backgroundColor('#0B7A5B')
        .onClick(() => this.bindElder())
      Text(this.bindSuccess ? '绑定后可以查看药品、计划、服药记录和健康告警。' : '绑定失败，请重新输入老人端绑定码。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor(this.bindSuccess ? '#0B7A5B' : '#B42318')
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PermissionCard() {
    Column({ space: 10 }) {
      Text('绑定权限')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(currentSession.role === 'guardian' ? '你可以查看' + getCurrentElder().name + '的药品、计划、服药记录、库存风险和健康告警。' : '家属绑定后，可以帮你查看用药记录和异常提醒。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Row({ space: 8 }) {
        this.PermissionPill('药品')
        this.PermissionPill('计划')
        this.PermissionPill('记录')
        this.PermissionPill('健康')
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder NotifyCard() {
    Column({ space: 14 }) {
      Text('通知设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('通知会发送给当前登录的家属看护人，不需要再填写联系人。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#52635F')
      this.NotifySwitch('漏服通知', '超过服药时间未确认时提醒家属', this.missedNotify, (value: boolean) => {
        this.missedNotify = value;
      })
      this.NotifySwitch('健康异常通知', '心率、血压或血糖异常时提醒家属', this.healthNotify, (value: boolean) => {
        this.healthNotify = value;
      })
      this.NotifySwitch('低库存通知', '常用药低于阈值时提醒补药', this.stockNotify, (value: boolean) => {
        this.stockNotify = value;
      })
      this.NotifySwitch('每日汇总通知', '晚间发送当天服药和健康摘要', this.dailySummary, (value: boolean) => {
        this.dailySummary = value;
      })
      Button('测试通知')
        .width('100%')
        .height(50)
        .fontSize(18)
        .borderRadius(18)
        .backgroundColor('#0B7A5B')
        .onClick(() => promptAction.showToast({ message: '通知设置可用' }))
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder NotificationFlowCard() {
    Column({ space: 10 }) {
      Text('通知闭环')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('未确认任务会进入待办，家属处理后会留下处置记录。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
        .padding(12)
        .borderRadius(16)
        .backgroundColor('#F6FEF9')
      Text('当前待办：' + this.nextRecord().time + ' ' + this.nextRecord().medicineName + '，状态：' + this.nextRecord().status)
        .fontSize(15)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder AlertCard() {
    Column({ space: 8 }) {
      Text('异常提醒')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#B42318')
      Text(getElderHealthAlerts().length > 0 ? getElderHealthAlerts()[0].title + '：' + getElderHealthAlerts()[0].value + '，已通知监护人。' : '当前没有异常提醒。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFF1F0')
    .alignItems(HorizontalAlign.Start)
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

  @Builder NotifySwitch(title: string, desc: string, value: boolean, change: (value: boolean) => void) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(desc)
          .fontSize(14)
          .lineHeight(21)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: value })
        .onChange(change)
    }
    .width('100%')
  }

  @Builder PermissionPill(text: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor('#0B7A5B')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(34)
      .borderRadius(14)
      .backgroundColor('#E7F5EF')
  }
}
