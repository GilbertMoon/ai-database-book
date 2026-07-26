(() => {
  const style = document.createElement('style');
  style.textContent = `
.num {
  min-width: 72px !important;
  text-align: left !important;
}
.home {
  left: 158px !important;
}
`;
  document.head.appendChild(style);
})();
