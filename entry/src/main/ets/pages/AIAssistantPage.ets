import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct AIAssistantPage {
  @State question: string = '这个药饭前吃还是饭后吃？';
  @State answer: string = '你可以先查看医生处方。根据当前记录，二甲双胍片通常建议餐后服用，以减少胃部不适。';
  @State voiceText: string = '';
  @State riskLevel: string = '中等风险';
  @State familyMessage: string = '妈妈今天中午 12:30 的二甲双胍片还没有打卡，请您方便时电话提醒一下。';

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header()
        this.QuestionCard()
        this.ConflictCard()
        this.RiskCard()
        this.VoiceCard()
        this.FamilyMessageCard()
        this.SafetyNote()
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder Header() {
    Row() {
      Column({ space: 6 }) {
        Text('AI 用药助手')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text('识别、解释、提醒和家属协助')
          .fontSize(15)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回')
        .height(38)
        .backgroundColor('#FFFFFF')
        .fontColor('#0E7C66')
        .onClick(() => router.back())
    }
    .width('100%')
  }

  @Builder QuestionCard() {
    Column({ space: 12 }) {
      this.CardTitle('用药问答', '老人看不懂说明书时，用简单语言解释')
      TextInput({ text: this.question, placeholder: '输入想问的问题' })
        .height(48)
        .backgroundColor('#F9FAFB')
        .borderRadius(14)
        .onChange((value: string) => {
          this.question = value;
        })
      Button('生成通俗解释')
        .width('100%')
        .height(44)
        .backgroundColor('#0E7C66')
        .onClick(() => {
          this.answer = 'AI解释：这个问题需要结合医生处方。当前演示数据中，二甲双胍片建议餐后服用；硝苯地平控释片建议每日固定时间服用。';
          promptAction.showToast({ message: '已生成 AI 用药解释（模拟）' });
        })
      Text(this.answer)
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#475467')
        .width('100%')
        .padding(12)
        .borderRadius(14)
        .backgroundColor('#F6FEF9')
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ConflictCard() {
    Column({ space: 12 }) {
      this.CardTitle('药品冲突提醒', '发现重复服药、相互影响或注意事项')
      Row() {
        Text('二甲双胍片 + 阿司匹林肠溶片')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text('需核对')
          .fontSize(13)
          .fontColor('#B54708')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(12)
          .backgroundColor('#FFF7ED')
      }
      .width('100%')
      Text('AI建议：当前没有直接判定为禁用，但老人同时服用多种慢病药时，应提醒家属核对医生处方，避免自行加减药。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#475467')
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RiskCard() {
    Column({ space: 12 }) {
      this.CardTitle('漏服风险分析', '根据历史记录预测容易漏服的时间段')
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.riskLevel)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D97706')
          Text('午间最容易漏服')
            .fontSize(14)
            .fontColor('#667085')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Button('优化提醒')
          .height(42)
          .backgroundColor('#EAF7F1')
          .fontColor('#0E7C66')
          .onClick(() => {
            this.riskLevel = '已优化';
            promptAction.showToast({ message: '已建议将午间提醒提前 10 分钟（模拟）' });
          })
      }
      .width('100%')
      Progress({ value: 68, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color('#D97706')
      Text('建议：午饭前 10 分钟先轻提醒，饭后 15 分钟强提醒；连续漏服时通知家属。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#475467')
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder VoiceCard() {
    Column({ space: 12 }) {
      this.CardTitle('语音录入药品', '不会打字时，直接说出药名和吃法')
      Button(this.voiceText === '' ? '按住说话（模拟）' : '重新语音录入')
        .width('100%')
        .height(48)
        .backgroundColor('#0E7C66')
        .onClick(() => {
          this.voiceText = '每天早饭后吃一片降压药，药名是硝苯地平控释片。';
          promptAction.showToast({ message: '已识别语音内容（模拟）' });
        })
      Text(this.voiceText === '' ? '识别后会自动拆分为药名、剂量和服用时间。' : this.voiceText)
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#475467')
        .width('100%')
        .padding(12)
        .borderRadius(14)
        .backgroundColor('#F9FAFB')
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder FamilyMessageCard() {
    Column({ space: 12 }) {
      this.CardTitle('家属提醒文案', '自动生成清楚、温和的提醒消息')
      Text(this.familyMessage)
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#14213D')
        .width('100%')
        .padding(14)
        .borderRadius(16)
        .backgroundColor('#F6FEF9')
      Row({ space: 10 }) {
        Button('重新生成')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#FFFFFF')
          .fontColor('#0E7C66')
          .onClick(() => {
            this.familyMessage = '张阿姨今天午间用药尚未确认，建议您稍后电话确认是否已经服用。';
          })
        Button('模拟发送')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#0E7C66')
          .onClick(() => promptAction.showToast({ message: '已发送给家属（模拟）' }))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder SafetyNote() {
    Text('安全说明：AI 只能辅助识别和提醒，不能代替医生诊断。药物剂量、禁忌和停药必须以医生处方为准。')
      .fontSize(13)
      .lineHeight(20)
      .fontColor('#667085')
      .width('100%')
      .padding(14)
      .borderRadius(16)
      .backgroundColor('#EEF2F6')
  }

  @Builder CardTitle(title: string, desc: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(desc)
        .fontSize(14)
        .fontColor('#667085')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
