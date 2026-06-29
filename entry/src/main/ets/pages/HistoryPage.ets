import { router } from '@kit.ArkUI';
import { MedicationRecord, historyRecords } from '../models/AppData';

@Entry
@Component
struct HistoryPage {
  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.Header('历史记录')
        ForEach(historyRecords, (item: MedicationRecord) => {
          Row() {
            Column({ space: 5 }) {
              Text(item.time).fontSize(17).fontWeight(FontWeight.Bold)
              Text(item.medicineName).fontSize(15).fontColor('#667085')
            }.alignItems(HorizontalAlign.Start)
            Blank()
            Text(item.status).fontSize(15).fontColor(item.status === '漏服' ? '#B42318' : '#0E7C66')
          }.width('100%').padding(16).borderRadius(14).backgroundColor('#FFFFFF')
        }, (item: MedicationRecord) => item.time + item.medicineName)
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
