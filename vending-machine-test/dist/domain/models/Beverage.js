"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Beverage = void 0;
const constants_1 = require("../constants");
class Beverage {
    name;
    recipe;
    sugarLevel;
    constructor(name, recipe, sugarLevel) {
        this.name = name;
        this.recipe = recipe;
        this.sugarLevel = sugarLevel;
    }
    canPrepare(ingredients) {
        for (const [ingredientName, quantity] of Object.entries(this.recipe)) {
            if (!ingredients[ingredientName] || ingredients[ingredientName].quantity < quantity) {
                return false;
            }
            if (!ingredients[constants_1.SUGAR] || ingredients['sugar'].quantity < this.sugarLevel) {
                return false;
            }
        }
        return true;
    }
    prepare(ingredients) {
        if (this.canPrepare(ingredients)) {
            for (const [ingredientName, quantity] of Object.entries(this.recipe)) {
                ingredients[ingredientName].use(quantity);
            }
            ingredients['sugar'].use(this.sugarLevel);
            return true;
        }
        return false;
    }
}
exports.Beverage = Beverage;
//# sourceMappingURL=Beverage.js.map