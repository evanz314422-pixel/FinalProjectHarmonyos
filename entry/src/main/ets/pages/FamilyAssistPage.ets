import { router, promptAction } from '@kit.ArkUI';
import { currentSession, healthAlerts, mockBindings } from '../models/AppData';

@Entry
@Component
struct FamilyAssistPage {
  @State shareEnabled: boolean = true;
  @State contact: string = '女儿 李女士 13800000002';
  @State bindCode: string = 'AX2026';
  @State bindSuccess: boolean = true;

  private bindElder(): void {
    if (this.bindCode === 'AX2026') {
      this.bindSuccess = true;
      promptAction.showToast({ message: '已绑定张阿姨（模拟）' });
    } else {
      this.bindSuccess = false;
      promptAction.showToast({ message: '绑定码不正确，请核对老人端显示的号码' });
    }
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
        this.NotifyCard()
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
      Text('AX2026')
        .fontSize(38)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0B7A5B')
      Text('把这个号码告诉家属，家属就可以在监护人端查看服药记录、库存和心率异常。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Text('已绑定：' + mockBindings[0].relation + ' 李女士')
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
      Text('输入老人端显示的绑定码，本地演示版默认使用 AX2026。')
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
      Button(this.bindSuccess ? '已绑定张阿姨' : '确认绑定')
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

  @Builder NotifyCard() {
    Column({ space: 12 }) {
      Text('通知设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      TextInput({ text: this.contact, placeholder: '紧急联系人' })
        .height(50)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.contact = value;
        })
      Row() {
        Text('漏服或心率异常时通知家属')
          .fontSize(17)
          .fontColor('#14213D')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.shareEnabled })
          .onChange((value: boolean) => {
            this.shareEnabled = value;
          })
      }
      .width('100%')
      Button('模拟发送提醒')
        .width('100%')
        .height(50)
        .fontSize(18)
        .borderRadius(18)
        .backgroundColor('#0B7A5B')
        .onClick(() => promptAction.showToast({ message: '已向监护人发送提醒（模拟）' }))
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder AlertCard() {
    Column({ space: 8 }) {
      Text('异常提醒')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#B42318')
      Text(healthAlerts.length > 0 ? healthAlerts[0].title + '：' + healthAlerts[0].value + '，已模拟通知监护人。' : '当前没有异常提醒。')
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
}
