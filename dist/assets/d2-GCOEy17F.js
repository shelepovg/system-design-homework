function e(n){switch(n){case"index":return`direction: down

Users: {
  label: "Пользователи"
}
System: {
  label: "Система"
}

Users -> System
`;case"context":return`direction: down

Users: {
  label: "Пользователи"
}
`;default:throw new Error("Unknown viewId: "+n)}}export{e as d2Source};
