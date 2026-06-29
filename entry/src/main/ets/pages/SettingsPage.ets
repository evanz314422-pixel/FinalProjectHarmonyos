import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State fontSize: number = 18;
  @State strongReminder: boolean = true;
  @State backupEnabled: boolean = false;

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('我的设置')
        Column({ space: 12 }) {
          Text('用户资料').fontSize(18).fontWeight(FontWeight.Bold)
          Text('使用者：张阿姨').fontSize(16)
          Text('慢病标签：高血压、糖尿病').fontSize(16).fontColor('#667085')
        }.width('100%').padding(16).borderRadius(14).backgroundColor('#FFFFFF').alignItems(HorizontalAlign.Start)
        Column({ space: 12 }) {
          Text('无障碍字体大小：' + this.fontSize.toString()).fontSize(17)
          Slider({ value: this.fontSize, min: 16, max: 28, step: 1 })
            .onChange((value: number) => { this.fontSize = value; })
          Row() {
            Text('强提醒模式').fontSize(17)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.strongReminder })
              .onChange((value: boolean) => { this.strongReminder = value; })
          }.width('100%')
          Row() {
            Text('本地备份').fontSize(17)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.backupEnabled })
              .onChange((value: boolean) => { this.backupEnabled = value; })
          }.width('100%')
          Button('导出备份文件').width('100%')
            .onClick(() => promptAction.showToast({ message: '已生成本地备份（模拟）' }))
        }.width('100%').padding(16).borderRadius(14).backgroundColor('#FFFFFF').alignItems(HorizontalAlign.Start)
      }.padding(18)
    }.backgroundColor('#F4F7FA')
  }

  @Builder Header(title: string) {
    Row() {
      Text(title).fontSize(26).fontWeight(FontWeight.Bold)
      Blank()
      Button('返回').onClick(() => router.back())
    }.width('100%')
  }
}
