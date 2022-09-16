// declare는 컴파일러에게 변수나 함수가 존재한다고 인식하게 하는 것
// 타입스크립트에서 문자열로 모듈을 지정해줄 경우 외부모듈로 인식한다.

interface Window {
  ethereum: any;
}

// .svg 확장자의 파일에서 ReactComponent의 존재를 인식시켜 주는 부분
declare module "*.svg" {
  import React = require("react");

  export const ReactComponent: REact.FC<React.SVGProps<SVGSVGElement>>;
  const src: string;
  export default src;
}

declare module "*.scss" {
  const content: { [className: string]: string };
  export = content;
}

declare module "*.png";
declare module "*.gif";
declare module "*.svg";
declare module "*.jpg";
