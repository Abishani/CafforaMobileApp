// Static assets served from web/public (see public/images and public/icons).
// Product images live in public/images/<Category>/ and the database stores
// only the public path in products.image_url (e.g. '/images/Beverages/Craft-Flat-White.jpg').

export const icons = {
  coffee: '/icons/coffee.svg',
  cart: '/icons/cart.svg',
  footerLine: '/icons/footer-line.svg',
  statusDot: '/icons/status-dot.svg',
  eye: '/icons/eye.svg',
}

export const auth = {
  bgPhoto: '/images/site/auth-background.png',
  avatar: '/images/site/auth-barista-avatar.png',
}

export const menuItemImages = {
  flatWhite: '/images/Beverages/Craft-Flat-White.jpg',
  cinnamonBun: '/images/Snacks/Cinnamon-Swirl-Bun.png',
  avocadoToast: '/images/Meals/Avocado-Sourdough-Toast.png',
  pistachioTart: '/images/Desserts/Pistachio-Raspberry-Tart.png',
  chocolateCookie: '/images/Desserts/Sourdough-Chocolate-Cookie.png',
  honeyOatLatte: '/images/Beverages/Iced-Honey-Oat-Latte.png',
  turkeyCiabatta: '/images/Meals/Smoked-Turkey-Ciabatta.png',
  matchaCrepe: '/images/Snacks/Matcha-Jasmine-Crepe.png',
}

export const home = {
  hero: '/images/site/home-hero.png',
  flatWhite: menuItemImages.flatWhite,
  cinnamonBun: menuItemImages.cinnamonBun,
  avocadoToast: menuItemImages.avocadoToast,
  pistachioTart: menuItemImages.pistachioTart,
}

export const menuIcons = {
  alertTriangle: '/icons/alert-triangle.svg',
  chevronRight: '/icons/chevron-right.svg',
  search: '/icons/search.svg',
  flame: '/icons/flame.svg',
  shoppingBag: '/icons/shopping-bag-white.svg',
}

export const cartIcons = {
  logOut: '/icons/log-out.svg',
  trash: '/icons/trash.svg',
  shoppingBag: '/icons/shopping-bag.svg',
  checkCircle: '/icons/check-circle.svg',
}

export const cartAvatar = '/images/site/customer-avatar.png'

export const adminIcons = {
  chartLine: '/icons/chart-line.svg',
  bookOpen: '/icons/book-open.svg',
  clipboardList: '/icons/clipboard-list.svg',
  settings: '/icons/settings.svg',
  plus: '/icons/plus.svg',
  pen: '/icons/pen.svg',
  trash: '/icons/trash.svg',
  chevronDown: '/icons/chevron-down.svg',
}

export const adminAvatar = '/images/site/admin-avatar.png'
