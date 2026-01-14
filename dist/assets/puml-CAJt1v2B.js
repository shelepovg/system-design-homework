function e(n){switch(n){case"index":return`@startuml
title "Landscape view"
top to bottom direction

hide stereotype
skinparam ranksep 60
skinparam nodesep 30
skinparam {
  arrowFontSize 10
  defaultTextAlignment center
  wrapWidth 200
  maxMessageSize 100
  shadowing false
}

skinparam rectangle<<Users>>{
  BackgroundColor #827a8e
  FontColor #ffffff
  BorderColor #6c6477
}
skinparam rectangle<<System>>{
  BackgroundColor #2b85e7
  FontColor #f1ffff
  BorderColor #1e73ce
}
rectangle "==Пользователи\\n\\nПользователи системы" <<Users>> as Users
rectangle "==Система\\n\\nСистема обработки пользовательских запросов" <<System>> as System

Users .[#8D8D8D,thickness=2].> System
@enduml
`;case"context":return`@startuml
title "Контекстная диаграмма"
top to bottom direction

hide stereotype
skinparam ranksep 60
skinparam nodesep 30
skinparam {
  arrowFontSize 10
  defaultTextAlignment center
  wrapWidth 200
  maxMessageSize 100
  shadowing false
}

skinparam rectangle<<Users>>{
  BackgroundColor #827a8e
  FontColor #ffffff
  BorderColor #6c6477
}
rectangle "==Пользователи\\n\\nПользователи системы" <<Users>> as Users
@enduml
`;default:throw new Error("Unknown viewId: "+n)}}export{e as pumlSource};
