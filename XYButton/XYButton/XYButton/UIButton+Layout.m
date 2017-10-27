//
//  UIButton+Layout.m
//  XYButton
//
//  Created by mxy on 2017/10/26.
//  Copyright © 2017年 mxy. All rights reserved.
//

#import "UIButton+Layout.h"
#import <objc/runtime.h>
@implementation UIButton (Layout)

#pragma mark - 运行时动态添加关联
//定义关联的key
static const char * titleRectKey = "titleRectKey";
static const char * imageRectKey = "imageRectKey";

- (CGRect)titleRect{
    return [objc_getAssociatedObject(self, titleRectKey) CGRectValue];
}

- (void)setTitleRect:(CGRect)rect{
    objc_setAssociatedObject(self, titleRectKey, [NSValue valueWithCGRect:rect], OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)imageRect{
    return [objc_getAssociatedObject(self, imageRectKey) CGRectValue];
}
- (void)setImageRect:(CGRect)rect {

    objc_setAssociatedObject(self, imageRectKey, [NSValue valueWithCGRect:rect], OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - 运行时动态替换方法
+ (void)load{
    MethodSwizzle(self, @selector(titleRectForContentRect:), @selector(override_titleRectForContentRect:));
    MethodSwizzle(self, @selector(imageRectForContentRect:), @selector(override_titleRectForContentRect:));
}

void MethodSwizzle(Class c,SEL origSEL,SEL overrideSEL){
    Method origMethod = class_getInstanceMethod(c, origSEL);//得到类的实例方法
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);

    //运行时函数class_addMethod 如果发现方法已经存在，会失败返回，也可以用来做检查用
    if (class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        //如果添加成功（在父类中重写方法）,指这个方法已经被替换过了，那么我们现在就需要将这次的新方法和上次遗留的方法交换使用class_replaceMethod这个方法
        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        //方法不存在就会交换
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

- (CGRect)override_titleRectForContentRect:(CGRect)contentRect{
    //判断self.titleRect不为空不为0
    if (!CGRectIsEmpty(self.titleRect) && !CGRectEqualToRect(self.titleRect, CGRectZero)) {
        return self.titleRect;
    }
    return [self override_titleRectForContentRect:contentRect];
}

- (CGRect)override_imageRectForContentRect:(CGRect)contentRect{
    //判断self.titleRect不为空不为0
    if (!CGRectIsEmpty(self.imageRect) && !CGRectEqualToRect(self.imageRect, CGRectZero)) {
        return self.imageRect;
    }
    return [self override_imageRectForContentRect:contentRect];
}
@end
