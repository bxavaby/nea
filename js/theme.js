/* ./js/theme.js */

class ThemeSwitcher {
  constructor() {
    this.themeColorMeta = document.getElementById("theme-color-meta");
    this.body = document.body;
    this.storageKey = "theme-preference";
    this.themes = {
      LIGHT: "sadakiyo5",
      DARK: "trash-panda",
    };
  }

  updateThemeColor() {
    if (!this.themeColorMeta) return;

    const backgroundColor = getComputedStyle(this.body)
      .getPropertyValue("--bg-meta")
      .trim();

    this.themeColorMeta.setAttribute("content", backgroundColor);
  }

  init() {
    const savedTheme = localStorage.getItem(this.storageKey);

    if (savedTheme && Object.values(this.themes).includes(savedTheme)) {
      this.setTheme(savedTheme);
    } else {
      const prefersDark = window.matchMedia(
        "(prefers-color-scheme: dark)",
      ).matches;
      this.setTheme(prefersDark ? this.themes.DARK : this.themes.LIGHT);
    }

    this.updateThemeColor();
  }

  toggleTheme() {
    const currentTheme = this.getCurrentTheme();
    const newTheme =
      currentTheme === this.themes.DARK ? this.themes.LIGHT : this.themes.DARK;
    this.setTheme(newTheme);

    setTimeout(() => this.updateThemeColor(), 0);
  }

  /**
   * Apply theme and save it to localStorage
   * @param {string}
   */
  setTheme(theme) {
    this.body.classList.remove(...Object.values(this.themes));
    this.body.classList.add(theme);
    localStorage.setItem(this.storageKey, theme);
  }

  /**
   * Get current theme from class
   * @returns {string}
   */
  getCurrentTheme() {
    return this.body.classList.contains(this.themes.DARK)
      ? this.themes.DARK
      : this.themes.LIGHT;
  }
}
