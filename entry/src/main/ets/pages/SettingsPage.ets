import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State fontSize: number = 18;
  @State bigTextMode: boolean = false;
  @State strongReminder: boolean = true;
  @State backupEnabled: boolean = false;
  @State emergencyContact: string = '李女士 13800000002';

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('我的设置')
        this.ProfileCard()
        this.AccessibilityCard()
        this.ReminderCard()
        this.ContactCard()
        this.BackupCard()
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder ProfileCard() {
    Column({ space: 10 }) {
      Text('用户资料')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('使用者：张阿姨')
        .fontSize(17)
        .fontColor('#52635F')
      Text('慢病标签：高血压、糖尿病')
        .fontSize(16)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder AccessibilityCard() {
    Column({ space: 14 }) {
      Text('看得清楚')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      this.SwitchRow('大字模式', '按钮和重要文字会更醒目', this.bigTextMode, (value: boolean) => {
        this.bigTextMode = value;
        this.fontSize = value ? 24 : 18;
      })
      Text('字体大小：' + this.fontSize.toString())
        .fontSize(17)
        .fontColor('#52635F')
      Slider({ value: this.fontSize, min: 16, max: 30, step: 1 })
        .onChange((value: number) => {
          this.fontSize = value;
        })
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ReminderCard() {
    Column({ space: 14 }) {
      Text('提醒方式')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      this.SwitchRow('强提醒模式', '适合容易忘记服药时开启', this.strongReminder, (value: boolean) => {
        this.strongReminder = value;
      })
      Text(this.strongReminder ? '已开启：模拟响铃、震动和稍后提醒。' : '已关闭：仅显示普通应用内提醒。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ContactCard() {
    Column({ space: 12 }) {
      Text('紧急联系人')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      TextInput({ text: this.emergencyContact, placeholder: '联系人姓名和电话' })
        .height(50)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.emergencyContact = value;
        })
      Button('模拟联系家属')
        .width('100%')
        .height(48)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#0B7A5B')
        .onClick(() => promptAction.showToast({ message: '已模拟联系紧急联系人' }))
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BackupCard() {
    Column({ space: 14 }) {
      Text('本地备份')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      this.SwitchRow('自动备份', '保存药品、计划和健康记录', this.backupEnabled, (value: boolean) => {
        this.backupEnabled = value;
      })
      Button('导出备份文件')
        .width('100%')
        .height(48)
        .fontSize(17)
        .borderRadius(16)
        .fontColor('#0B7A5B')
        .backgroundColor('#E7F5EF')
        .onClick(() => promptAction.showToast({ message: '已生成本地备份（模拟）' }))
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder SwitchRow(title: string, desc: string, value: boolean, change: (value: boolean) => void) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(desc)
          .fontSize(15)
          .lineHeight(22)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: value })
        .onChange(change)
    }
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
        .height(42)
        .fontSize(17)
        .borderRadius(16)
        .fontColor('#0B7A5B')
        .backgroundColor('#FFFFFF')
        .onClick(() => router.back())
    }
    .width('100%')
  }
}
