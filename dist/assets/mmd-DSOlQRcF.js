function e(n){switch(n){case"index":return`---
title: "Landscape view"
---
graph TB
  Users[Пользователи]
  System[Система]
  Users -.-> System
`;case"context":return`---
title: "Контекстная диаграмма"
---
graph TB
  Users[Пользователи]
`;default:throw new Error("Unknown viewId: "+n)}}export{e as mmdSource};
