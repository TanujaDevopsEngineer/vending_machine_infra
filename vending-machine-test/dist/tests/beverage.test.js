"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Beverage_1 = require("../domain/models/Beverage");
const Ingredient_1 = require("../domain/models/Ingredient");
describe('Beverage', () => {
    let ingredients;
    beforeEach(() => {
        ingredients = {
            water: new Ingredient_1.Ingredient('water', 10),
            sugar: new Ingredient_1.Ingredient('sugar', 10),
            coffee: new Ingredient_1.Ingredient('coffee', 10),
        };
    });
    test('should prepare beverage if ingredients are sufficient', () => {
        const coffee = new Beverage_1.Beverage('coffee', { water: 1, coffee: 1 }, 2);
        expect(coffee.prepare(ingredients)).toBe(true);
        expect(ingredients['water'].quantity).toBe(9);
        expect(ingredients['coffee'].quantity).toBe(9);
        expect(ingredients['sugar'].quantity).toBe(8);
    });
    test('should not prepare beverage if ingredients are not sufficient', () => {
        const coffee = new Beverage_1.Beverage('coffee', { water: 1, coffee: 11, sugar: 5 }, 2);
        expect(coffee.prepare(ingredients)).toBe(false);
        expect(ingredients['water'].quantity).toBe(10);
        expect(ingredients['coffee'].quantity).toBe(10);
        expect(ingredients['sugar'].quantity).toBe(10);
    });
    test('should not prepare beverage if ingredients do not exist', () => {
        const latte = new Beverage_1.Beverage('latte', { milk: 2, coffee: 1 }, 2);
        expect(latte.prepare(ingredients)).toBe(false);
        expect(ingredients['water'].quantity).toBe(10);
        expect(ingredients['coffee'].quantity).toBe(10);
        expect(ingredients['sugar'].quantity).toBe(10);
    });
});
//# sourceMappingURL=beverage.test.js.map