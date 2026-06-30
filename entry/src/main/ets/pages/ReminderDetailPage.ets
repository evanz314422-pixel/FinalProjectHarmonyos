import { router, promptAction } from '@kit.ArkUI';
import { getSelectedReminder, MedicationRecord } from '../models/AppData';

@Entry
@Component
struct ReminderDetailPage {
  @State refreshToken: number = 0;

  private currentReminder(): MedicationRecord {
    return getSelectedReminder();
  }

  private markDone(): void {
    this.currentReminder().status = '已服用';
    this.currentReminder().source = '老人确认';
    this.refreshToken++;
    promptAction.showToast({ message: '已记录为按时服用' });
  }

  build() {
    Column({ space: 18 }) {
      this.Header('今日提醒详情')
      Column({ space: 14 }) {
        Text(this.currentReminder().time).fontSize(42).fontWeight(FontWeight.Bold).fontColor('#0E7C66')
        Text(this.currentReminder().medicineName).fontSize(26).fontWeight(FontWeight.Bold)
        Text('状态：' + this.currentReminder().status + '  |  来源：' + (this.currentReminder().source === undefined ? '系统未响应' : this.currentReminder().source)).fontSize(17).fontColor('#667085')
        Progress({ value: 50, total: 100, type: ProgressType.Linear }).width('100%').color('#0E7C66')
        Text('如已服用，请在这里确认；如果不确定，建议联系家属核对。').fontSize(15).fontColor('#667085')
        Button('已按时服用').width('100%').height(48).backgroundColor('#0E7C66')
          .onClick(() => this.markDone())
        Button('稍后提醒').width('100%').onClick(() => promptAction.showToast({ message: '10 分钟后再次提醒' }))
      }
      .width('100%')
      .padding(20)
      .borderRadius(18)
      .backgroundColor('#FFFFFF')
    }
    .padding(18)
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder Header(title: string) {
    Row() {
      Text(title).fontSize(26).fontWeight(FontWeight.Bold)
      Blank()
      Button('返回').onClick(() => router.back())
    }.width('100%')
  }
}
