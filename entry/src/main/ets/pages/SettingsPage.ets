import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State bigTextMode: boolean = false;
  @State strongReminder: boolean = true;

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('我的设置')
        this.AccessibilityCard()
        this.ReminderCard()
        this.ContactCard()
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder AccessibilityCard() {
    Column({ space: 14 }) {
      Text('字大一点')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('看不清时，打开大字模式。')
        .fontSize(17)
        .lineHeight(25)
        .fontColor('#52635F')
      Row({ space: 10 }) {
        Button('普通字')
          .layoutWeight(1)
          .height(52)
          .fontSize(18)
          .borderRadius(18)
          .fontColor(this.bigTextMode ? '#52635F' : '#FFFFFF')
          .backgroundColor(this.bigTextMode ? '#F2F4F7' : '#0B7A5B')
          .onClick(() => {
            this.bigTextMode = false;
          })
        Button('大字')
          .layoutWeight(1)
          .height(52)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .fontColor(this.bigTextMode ? '#FFFFFF' : '#0B7A5B')
          .backgroundColor(this.bigTextMode ? '#0B7A5B' : '#E7F5EF')
          .onClick(() => {
            this.bigTextMode = true;
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ReminderCard() {
    Column({ space: 14 }) {
      Text('提醒响一点')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      this.SwitchRow('强提醒', '容易忘记吃药时打开', this.strongReminder, (value: boolean) => {
        this.strongReminder = value;
      })
      Text(this.strongReminder ? '已打开：提醒会更明显。' : '已关闭：只显示普通提醒。')
        .fontSize(17)
        .lineHeight(25)
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
      Text('联系家属')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('不舒服或看不懂药时，直接让家属帮你。')
        .fontSize(17)
        .lineHeight(25)
        .fontColor('#52635F')
      Text('李女士 13800000002')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Button('叫家属帮忙')
        .width('100%')
        .height(56)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .borderRadius(18)
        .backgroundColor('#0B7A5B')
        .onClick(() => promptAction.showToast({ message: '已提醒家属' }))
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
