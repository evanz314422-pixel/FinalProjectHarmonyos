import { router, promptAction } from '@kit.ArkUI';
import { deleteSelectedPlan, getSelectedPlan, MedicationPlan, setSelectedPlanEnabled, startEditSelectedPlan } from '../models/AppData';

@Entry
@Component
struct PlanDetailPage {
  @State planEnabled: boolean = true;

  private currentPlan(): MedicationPlan {
    return getSelectedPlan();
  }

  private deletePlan(): void {
    const removedName: string = deleteSelectedPlan();
    promptAction.showToast({ message: '已删除' + removedName + '用药计划' });
    router.back();
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
                setSelectedPlanEnabled(value);
                this.planEnabled = value;
                promptAction.showToast({ message: value ? '计划已启用，今日记录已同步' : '计划已暂停，未完成提醒已移除' });
              })
          }.width('100%')
          Button('修改计划').width('100%').onClick(() => {
            startEditSelectedPlan();
            router.pushUrl({ url: 'pages/AddPlanPage' });
          })
          Button('删除计划').width('100%').backgroundColor('#B42318')
            .onClick(() => this.deletePlan())
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
