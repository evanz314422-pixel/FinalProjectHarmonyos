import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct PlanDetailPage {
  @State planEnabled: boolean = true;

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('计划详情')
        Column({ space: 14 }) {
          Text('二甲双胍片长期计划').fontSize(24).fontWeight(FontWeight.Bold)
          Text('每日 3 次：08:00、12:30、18:30').fontSize(16)
          Text('每次 1 片，餐后服用').fontSize(16)
          Row() {
            Text('计划状态').fontSize(17)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.planEnabled })
              .onChange((value: boolean) => { this.planEnabled = value; })
          }.width('100%')
          Button('修改计划').width('100%').onClick(() => router.pushUrl({ url: 'pages/AddPlanPage' }))
          Button('删除计划').width('100%').backgroundColor('#B42318')
            .onClick(() => promptAction.showDialog({ title: '删除计划', message: '课堂演示中仅模拟删除操作。' }))
        }
        .width('100%')
        .padding(18)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
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
