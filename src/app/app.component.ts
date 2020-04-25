import { Component } from '@angular/core';

@Component({
  selector: 'lsl-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Letslearn'; // adding comments
  points = 1;

  plus1() {
    this.points++;
  }

  reset() {
    this.points = 0;
  }
}
