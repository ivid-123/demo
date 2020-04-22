
import { browser, by, element } from 'protractor';

export class LetslearnPage {
  navigateTo() {
    return browser.get('/');
  }

  getTitleText() {
    return element(by.css('h1')).getText();
  }

  getPoints() {
    return element(by.cssContainingText('div', 'Points')).$('span').getText();
  }

  getPlus1Button() {
    return element(by.cssContainingText('button', 'Plus 1'));
  }

  getResetButton() {
    return element(by.cssContainingText('button', 'Reset'));
  }
}