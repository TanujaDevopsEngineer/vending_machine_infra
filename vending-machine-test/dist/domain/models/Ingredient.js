"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Ingredient = void 0;
class Ingredient {
    name;
    quantity;
    constructor(name, quantity) {
        this.name = name;
        this.quantity = quantity;
    }
    use(amount) {
        if (this.quantity >= amount) {
            this.quantity -= amount;
            return true;
        }
        return false;
    }
    refill(amount) {
        this.quantity += amount;
    }
}
exports.Ingredient = Ingredient;
//# sourceMappingURL=Ingredient.js.map