import { router, promptAction } from '@kit.ArkUI';
import { getWatchedElderId, plans } from '../models/AppData';

@Entry
@Component
struct AddPlanPage {
  @State medicine: string = '二甲双胍片';
  @State timeOne: string = '08:00';
  @State timeTwo: string = '12:30';
  @State timeThree: string = '18:30';
  @State strongReminder: boolean = true;

  private savePlan(): void {
    const nextId: number = plans.length + 1;
    plans.push({
      id: nextId,
      elderId: getWatchedElderId(),
      medicineName: this.medicine,
      times: [this.timeOne, this.timeTwo, this.timeThree],
      dosage: '1片',
      mealTime: '饭后',
      enabled: true
    });
    promptAction.showToast({ message: '用药计划已保存' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('新增用药计划')
        this.InputCard('选择药品', this.medicine, (value: string) => { this.medicine = value; })
        this.InputCard('第一次提醒', this.timeOne, (value: string) => { this.timeOne = value; })
        this.InputCard('第二次提醒', this.timeTwo, (value: string) => { this.timeTwo = value; })
        this.InputCard('第三次提醒', this.timeThree, (value: string) => { this.timeThree = value; })
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
        Button('保存计划').width('100%').height(48).backgroundColor('#0E7C66')
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
