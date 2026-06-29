import { router, promptAction } from '@kit.ArkUI';
import { UserRole, setSession } from '../models/AppData';

type AuthStep = 'chooseRole' | 'login' | 'register' | 'bindElder';

@Entry
@Component
struct LoginPage {
  @State authStep: AuthStep = 'chooseRole';
  @State selectedRole: UserRole = 'elder';
  @State phone: string = '';
  @State code: string = '';
  @State userName: string = '';
  @State bindCode: string = 'AX2026';

  private chooseRole(role: UserRole): void {
    this.selectedRole = role;
    this.authStep = 'login';
  }

  private enterApp(role: UserRole): void {
    setSession(role);
    promptAction.showToast({ message: role === 'elder' ? '已进入老人端' : '已进入家属端' });
    router.replaceUrl({ url: 'pages/Index' });
  }

  private submitRegister(): void {
    if (this.selectedRole === 'guardian') {
      this.authStep = 'bindElder';
      promptAction.showToast({ message: '家属账号已创建，请绑定老人（模拟）' });
    } else {
      promptAction.showToast({ message: '老人账号已创建（模拟）' });
      this.enterApp('elder');
    }
  }

  private submitBind(): void {
    if (this.bindCode === 'AX2026') {
      promptAction.showToast({ message: '已绑定张阿姨（模拟）' });
      this.enterApp('guardian');
    } else {
      promptAction.showToast({ message: '绑定码不正确，请输入 AX2026' });
    }
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        this.BrandHeader()
        if (this.authStep === 'chooseRole') {
          this.ChooseRolePanel()
        } else if (this.authStep === 'bindElder') {
          this.BindPanel()
        } else {
          this.AuthPanel()
        }
      }
      .padding({ left: 22, right: 22, top: 34, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF7F1')
  }

  @Builder BrandHeader() {
    Column({ space: 8 }) {
      Text('安心服药助手')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#102A27')
      Text(this.authStep === 'chooseRole' ? '先选择使用身份，后面只显示需要的操作。' : this.selectedRole === 'elder' ? '老人端：提醒吃药，也能自己添加药品。' : '家属端：帮家人管理药品和健康异常。')
        .fontSize(18)
        .lineHeight(26)
        .fontColor('#52635F')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ChooseRolePanel() {
    Column({ space: 14 }) {
      this.RoleCard('我是老人', '我自己用，提醒我按时吃药，也可以自己添加药品。', '进入老人登录', 'elder', true)
      this.RoleCard('我是家属', '我照顾家人，查看服药记录和健康异常。', '进入家属登录', 'guardian', false)
      Button('直接体验老人端')
        .width('100%')
        .height(44)
        .fontSize(17)
        .borderRadius(18)
        .fontColor('#0B7A5B')
        .backgroundColor('#FAF7F1')
        .onClick(() => this.enterApp('elder'))
    }
    .width('100%')
  }

  @Builder AuthPanel() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .height(40)
          .fontSize(16)
          .borderRadius(16)
          .fontColor('#0B7A5B')
          .backgroundColor('#E7F5EF')
          .onClick(() => {
            this.authStep = 'chooseRole';
          })
        Blank()
        Text(this.selectedRole === 'elder' ? '老人登录' : '家属登录')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
      }
      .width('100%')

      if (this.authStep === 'register') {
        this.InputField('称呼', this.selectedRole === 'elder' ? '例如：张阿姨' : '例如：李女士', this.userName, (value: string) => {
          this.userName = value;
        })
      }

      this.InputField('手机号', '请输入手机号', this.phone, (value: string) => {
        this.phone = value;
      })
      this.CodeField()

      Button(this.authStep === 'register' ? (this.selectedRole === 'elder' ? '注册老人账号' : '注册家属账号') : (this.selectedRole === 'elder' ? '进入老人端' : '进入家属端'))
        .width('100%')
        .height(58)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .borderRadius(22)
        .backgroundColor('#0B7A5B')
        .onClick(() => {
          if (this.authStep === 'register') {
            this.submitRegister();
          } else {
            this.enterApp(this.selectedRole);
          }
        })

      Button(this.authStep === 'register' ? '已有账号，去登录' : (this.selectedRole === 'elder' ? '没有账号？注册老人账号' : '没有账号？注册家属账号'))
        .width('100%')
        .height(44)
        .fontSize(17)
        .borderRadius(18)
        .fontColor('#0B7A5B')
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          this.authStep = this.authStep === 'register' ? 'login' : 'register';
        })
    }
    .width('100%')
    .padding(20)
    .borderRadius(26)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BindPanel() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .height(40)
          .fontSize(16)
          .borderRadius(16)
          .fontColor('#0B7A5B')
          .backgroundColor('#E7F5EF')
          .onClick(() => {
            this.authStep = 'register';
          })
        Blank()
        Text('绑定老人')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
      }
      .width('100%')
      Text('把老人手机上的绑定码填到这里。演示绑定码为 AX2026。')
        .fontSize(17)
        .lineHeight(25)
        .fontColor('#52635F')
      this.InputField('绑定码', 'AX2026', this.bindCode, (value: string) => {
        this.bindCode = value;
      })
      Button('完成绑定并进入')
        .width('100%')
        .height(58)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .borderRadius(22)
        .backgroundColor('#0B7A5B')
        .onClick(() => this.submitBind())
    }
    .width('100%')
    .padding(20)
    .borderRadius(26)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RoleCard(title: string, desc: string, action: string, role: UserRole, primary: boolean) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(desc)
        .fontSize(17)
        .lineHeight(25)
        .fontColor('#52635F')
      Button(action)
        .width('100%')
        .height(58)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .borderRadius(22)
        .fontColor(primary ? '#FFFFFF' : '#0B7A5B')
        .backgroundColor(primary ? '#0B7A5B' : '#E7F5EF')
        .onClick(() => this.chooseRole(role))
    }
    .width('100%')
    .padding(20)
    .borderRadius(26)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder CodeField() {
    Row({ space: 10 }) {
      Column({ space: 8 }) {
        Text('验证码')
          .fontSize(16)
          .fontColor('#52635F')
        TextInput({ text: this.code, placeholder: '6 位验证码' })
          .height(50)
          .fontSize(18)
          .borderRadius(16)
          .backgroundColor('#F6F8F7')
          .onChange((value: string) => {
            this.code = value;
          })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Button('获取验证码')
        .height(50)
        .fontSize(16)
        .borderRadius(16)
        .fontColor('#0B7A5B')
        .backgroundColor('#E7F5EF')
        .onClick(() => promptAction.showToast({ message: '验证码已发送（模拟）' }))
    }
    .width('100%')
  }

  @Builder InputField(label: string, placeholder: string, value: string, change: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(16)
        .fontColor('#52635F')
      TextInput({ text: value, placeholder: placeholder })
        .height(50)
        .fontSize(18)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange(change)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
