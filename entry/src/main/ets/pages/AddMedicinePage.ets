import { router, promptAction } from '@kit.ArkUI';
import { addMedicineForElder, currentSession } from '../models/AppData';

@Entry
@Component
struct AddMedicinePage {
  @State name: string = '';
  @State spec: string = '';
  @State dosage: string = '';
  @State stock: string = '';
  @State note: string = '';
  @State aiRecognized: boolean = false;
  @State recognizing: boolean = false;

  private fillRecognizedMedicine(): void {
    this.name = '硝苯地平控释片';
    this.spec = '30mg x 7片';
    this.dosage = '1片';
    this.stock = '7';
    this.note = 'AI识别：常用于血压管理。建议每日固定时间服用，具体用法请以医生处方为准。';
  }

  private saveMedicine(): void {
    const stockValue: number = this.stock === '' ? 0 : Number(this.stock);
    addMedicineForElder(this.name, this.spec, this.dosage, stockValue, this.note);
    promptAction.showToast({ message: currentSession.role === 'guardian' ? '已替老人保存药品（模拟）' : '已保存到常用药（模拟）' });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header(currentSession.role === 'guardian' ? '替老人添加药品' : '新增药品')
        this.AiCaptureCard()
        Button('进入 AI 用药助手')
          .width('100%')
          .height(48)
          .borderRadius(18)
          .backgroundColor('#FFFFFF')
          .fontColor('#0B7A5B')
          .onClick(() => router.pushUrl({ url: 'pages/AIAssistantPage' }))

        if (this.aiRecognized) {
          this.RecognitionResultCard()
        }

        this.Field('药品名称', '例如：二甲双胍片', this.name, (value: string) => {
          this.name = value;
        })
        this.Field('规格包装', '例如：0.5g x 30片', this.spec, (value: string) => {
          this.spec = value;
        })
        this.Field('默认剂量', '例如：1片', this.dosage, (value: string) => {
          this.dosage = value;
        })
        this.Field('当前库存', '例如：30', this.stock, (value: string) => {
          this.stock = value;
        })
        this.Field('注意事项', '饭前饭后、禁忌或医生叮嘱', this.note, (value: string) => {
          this.note = value;
        })

        Button('保存到常用药')
          .width('100%')
          .height(54)
          .fontSize(19)
          .borderRadius(20)
          .backgroundColor('#0B7A5B')
          .onClick(() => this.saveMedicine())

        Text('提示：AI 识别只能辅助录入，最终药名、剂量和服用方式应由本人或监护人与医生处方核对。')
          .fontSize(13)
          .lineHeight(20)
          .fontColor('#667085')
          .width('100%')
      }
      .padding(18)
    }
    .backgroundColor('#F5F7FA')
    .width('100%')
    .height('100%')
  }

  @Builder Header(title: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text('拍照识别或手动录入药品信息')
          .fontSize(15)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回')
        .height(40)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .fontColor('#0B7A5B')
        .onClick(() => router.back())
    }
    .width('100%')
  }

  @Builder AiCaptureCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 6 }) {
          Text('拍照识别药品')
            .fontSize(21)
            .fontWeight(FontWeight.Bold)
            .fontColor('#102A27')
          Text('适合看不清药名、不方便打字时快速录入')
            .fontSize(14)
            .fontColor('#667085')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text('AI')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(44)
          .height(44)
          .textAlign(TextAlign.Center)
          .borderRadius(14)
          .backgroundColor('#0B7A5B')
      }
      .width('100%')

      Row({ space: 10 }) {
        Button(this.recognizing ? '识别中...' : '拍照识别')
          .layoutWeight(1)
          .height(48)
          .borderRadius(18)
          .backgroundColor('#0B7A5B')
          .onClick(() => {
            this.recognizing = true;
            this.fillRecognizedMedicine();
            this.aiRecognized = true;
            this.recognizing = false;
            promptAction.showToast({ message: '已识别药盒文字，请确认后保存' });
          })

        Button('相册导入')
          .layoutWeight(1)
          .height(48)
          .borderRadius(18)
          .backgroundColor('#FFFFFF')
          .fontColor('#0B7A5B')
          .onClick(() => {
            this.fillRecognizedMedicine();
            this.aiRecognized = true;
            promptAction.showToast({ message: '已模拟从相册识别药品' });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#E7F5EF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RecognitionResultCard() {
    Column({ space: 10 }) {
      Row() {
        Text('识别结果待确认')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text('可信度 92%')
          .fontSize(13)
          .fontColor('#0B7A5B')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(12)
          .backgroundColor('#EAF7F1')
      }
      .width('100%')

      Text('识别到：硝苯地平控释片，30mg x 7片。系统已自动填入下方表单。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#475467')

      Row({ space: 10 }) {
        Button('重新识别')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#FFFFFF')
          .fontColor('#0B7A5B')
          .onClick(() => promptAction.showToast({ message: '请重新拍摄药盒正面（模拟）' }))
        Button('确认无误')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#0B7A5B')
          .onClick(() => promptAction.showToast({ message: '已确认识别结果' }))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder Field(label: string, placeholder: string, value: string, change: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(15)
        .fontColor('#667085')
      TextInput({ text: value, placeholder: placeholder })
        .height(50)
        .fontSize(17)
        .borderRadius(14)
        .backgroundColor('#F9FAFB')
        .onChange(change)
    }
    .width('100%')
    .padding(14)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }
}
