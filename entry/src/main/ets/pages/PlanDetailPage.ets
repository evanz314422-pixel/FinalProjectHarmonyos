import { router, promptAction } from '@kit.ArkUI';
import { getSelectedPlan, MedicationPlan } from '../models/AppData';

@Entry
@Component
struct PlanDetailPage {
  @State planEnabled: boolean = true;

  private currentPlan(): MedicationPlan {
    return getSelectedPlan();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('计划详情')
        Column({ space: 14 }) {
          Text(this.currentPlan().medicineName + '长期计划').fontSize(24).fontWeight(FontWeight.Bold)
          Text('每日 ' + this.currentPlan().times.length.toString() + ' 次：' + this.currentPlan().times.join('、')).fontSize(16)
          Text('每次 ' + this.currentPlan().dosage + '，' + this.currentPlan().mealTime + '服用').fontSize(16)
          Row() {
            Text('计划状态').fontSize(17)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.currentPlan().enabled })
              .onChange((value: boolean) => {
                this.currentPlan().enabled = value;
                this.planEnabled = value;
              })
          }.width('100%')
          Button('修改计划').width('100%').onClick(() => router.pushUrl({ url: 'pages/AddPlanPage' }))
          Button('删除计划').width('100%').backgroundColor('#B42318')
            .onClick(() => promptAction.showDialog({ title: '删除计划', message: '删除后将停止该计划提醒。' }))
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
