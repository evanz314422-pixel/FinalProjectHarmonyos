import { router } from '@kit.ArkUI';
import { getElderPlans, getMedicinePhotoColor, getMedicinePhotoLabel, getMedicinePhotoUri, isMedicinePhotoUploaded, MedicationPlan, selectPlan, startCreatePlan } from '../models/AppData';

@Entry
@Component
struct PlanListPage {
  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.Header('用药计划')
        Button('+ 新增计划').width('100%').onClick(() => {
          startCreatePlan();
          router.pushUrl({ url: 'pages/AddPlanPage' });
        })
        ForEach(getElderPlans(), (plan: MedicationPlan) => {
          Row({ space: 12 }) {
            this.MedicinePhoto(plan.medicineName, 58)
            Column({ space: 6 }) {
              Text(plan.medicineName).fontSize(20).fontWeight(FontWeight.Bold)
              Text(plan.times.join(' / ') + '  ' + plan.dosage + '  ' + plan.mealTime).fontSize(14).fontColor('#667085')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Text(plan.enabled ? '启用' : '暂停').fontColor(plan.enabled ? '#0E7C66' : '#98A2B3')
          }
          .width('100%')
          .padding(16)
          .borderRadius(14)
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            selectPlan(plan.id);
            router.pushUrl({ url: 'pages/PlanDetailPage' });
          })
        }, (plan: MedicationPlan) => plan.id.toString() + plan.enabled.toString() + plan.times.join('-'))
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

  @Builder MedicinePhoto(name: string, size: number) {
    Stack() {
      if (getMedicinePhotoUri(name) !== '') {
        Image(getMedicinePhotoUri(name)).width(size).height(size).borderRadius(16).objectFit(ImageFit.Cover)
      } else {
        Column({ space: 3 }) {
          Text(getMedicinePhotoLabel(name)).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#102A27').maxLines(1)
          Text(isMedicinePhotoUploaded(name) ? '药图' : '待传').fontSize(9).fontColor('#0B7A5B')
        }
        .width(size)
        .height(size)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width(size)
    .height(size)
    .borderRadius(16)
    .backgroundColor(getMedicinePhotoColor(name))
    .border({ width: 2, color: '#FFFFFF' })
  }
}
