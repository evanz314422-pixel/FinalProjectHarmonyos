import { router, promptAction } from '@kit.ArkUI';
import {
  getPlanFormDosage,
  getPlanFormMealTime,
  getPlanFormMedicine,
  getPlanFormTime,
  getPlanFormTitle,
  isEditingMedicationPlan,
  saveMedicationPlanForElder
} from '../models/AppData';

@Entry
@Component
struct AddPlanPage {
  @State medicine: string = getPlanFormMedicine();
  @State timeOne: string = getPlanFormTime(0);
  @State timeTwo: string = getPlanFormTime(1);
  @State timeThree: string = getPlanFormTime(2);
  @State dosage: string = getPlanFormDosage();
  @State mealTime: string = getPlanFormMealTime();
  @State strongReminder: boolean = true;

  private savePlan(): void {
    const times: string[] = [];
    if (this.timeOne !== '') {
      times.push(this.timeOne);
    }
    if (this.timeTwo !== '') {
      times.push(this.timeTwo);
    }
    if (this.timeThree !== '') {
      times.push(this.timeThree);
    }
    if (this.medicine === '' || times.length === 0) {
      promptAction.showToast({ message: '请填写药品和至少一个提醒时间' });
      return;
    }
    const isEditing: boolean = isEditingMedicationPlan();
    saveMedicationPlanForElder(
      this.medicine,
      times,
      this.dosage === '' ? '按医嘱' : this.dosage,
      this.mealTime === '' ? '按医嘱' : this.mealTime
    );
    promptAction.showToast({ message: isEditing ? '用药计划已更新，今日记录已同步' : '用药计划已保存，今日服药记录已同步' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header(getPlanFormTitle())
        this.InputCard('选择药品', this.medicine, (value: string) => { this.medicine = value; })
        this.InputCard('第一次提醒', this.timeOne, (value: string) => { this.timeOne = value; })
        this.InputCard('第二次提醒', this.timeTwo, (value: string) => { this.timeTwo = value; })
        this.InputCard('第三次提醒', this.timeThree, (value: string) => { this.timeThree = value; })
        this.InputCard('每次剂量', this.dosage, (value: string) => { this.dosage = value; })
        this.InputCard('服用时机', this.mealTime, (value: string) => { this.mealTime = value; })
        Row() {
          Text('开启强提醒').fontSize(17)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.strongReminder })
            .onChange((value: boolean) => { this.strongReminder = value; })
        }
        .width('100%')
        .padding(16)
        .borderRadius(14)
        .backgroundColor('#FFFFFF')
        Button(isEditingMedicationPlan() ? '保存修改' : '保存计划').width('100%').height(48).backgroundColor('#0E7C66')
          .onClick(() => this.savePlan())
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

  @Builder InputCard(label: string, value: string, change: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label).fontSize(15).fontColor('#667085')
      TextInput({ text: value }).height(46).onChange(change)
    }.width('100%').padding(14).borderRadius(14).backgroundColor('#FFFFFF').alignItems(HorizontalAlign.Start)
  }
}
