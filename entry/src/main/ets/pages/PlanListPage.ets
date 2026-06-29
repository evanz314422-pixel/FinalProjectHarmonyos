import { router } from '@kit.ArkUI';
import { MedicationPlan, plans } from '../models/AppData';

@Entry
@Component
struct PlanListPage {
  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.Header('用药计划')
        Button('+ 新增计划').width('100%').onClick(() => router.pushUrl({ url: 'pages/AddPlanPage' }))
        ForEach(plans, (plan: MedicationPlan) => {
          Row() {
            Column({ space: 6 }) {
              Text(plan.medicineName).fontSize(20).fontWeight(FontWeight.Bold)
              Text(plan.times.join(' / ') + '  ' + plan.dosage + '  ' + plan.mealTime).fontSize(14).fontColor('#667085')
            }.alignItems(HorizontalAlign.Start)
            Blank()
            Text(plan.enabled ? '启用' : '暂停').fontColor(plan.enabled ? '#0E7C66' : '#98A2B3')
          }
          .width('100%')
          .padding(16)
          .borderRadius(14)
          .backgroundColor('#FFFFFF')
          .onClick(() => router.pushUrl({ url: 'pages/PlanDetailPage' }))
        }, (plan: MedicationPlan) => plan.id.toString())
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
