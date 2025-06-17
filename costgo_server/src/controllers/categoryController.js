const Category = require('../models/Category');

// 모든 카테고리 목록 가져오기
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find({}).sort({ name: 1 }); // 이름순 정렬
    res.status(200).json(categories);
  } catch (error) {
    res.status(500).json({ message: '카테고리 목록을 가져오는 중 오류 발생', error: error.message });
  }
};

// 새 메인 카테고리 추가
exports.addMainCategory = async (req, res) => {
  try {
    const { name, iconPath } = req.body;
    const newCategory = new Category({ name, iconPath });
    const savedCategory = await newCategory.save();
    res.status(201).json(savedCategory);
  } catch (error) {
    res.status(400).json({ message: '메인 카테고리 추가 중 오류 발생', error: error.message });
  }
};

// 메인 카테고리 수정
exports.updateMainCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, iconPath } = req.body;
    const updatedCategory = await Category.findByIdAndUpdate(
      id,
      { name, iconPath },
      { new: true, runValidators: true }
    );
    if (!updatedCategory) {
      return res.status(404).json({ message: '해당 ID의 메인 카테고리를 찾을 수 없습니다.' });
    }
    res.status(200).json(updatedCategory);
  } catch (error) {
    res.status(400).json({ message: '메인 카테고리 수정 중 오류 발생', error: error.message });
  }
};

// 메인 카테고리 삭제
exports.deleteMainCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedCategory = await Category.findByIdAndDelete(id);
    if (!deletedCategory) {
      return res.status(404).json({ message: '해당 ID의 메인 카테고리를 찾을 수 없습니다.' });
    }
    res.status(200).json({ message: '메인 카테고리가 성공적으로 삭제되었습니다.' });
  } catch (error) {
    res.status(500).json({ message: '메인 카테고리 삭제 중 오류 발생', error: error.message });
  }
};

// --- 서브 카테고리 컨트롤러 ---

// 서브 카테고리 추가
exports.addSubCategory = async (req, res) => {
  try {
    const { mainId } = req.params;
    const { name } = req.body;
    const mainCategory = await Category.findById(mainId);
    if (!mainCategory) {
      return res.status(404).json({ message: '메인 카테고리를 찾을 수 없습니다.' });
    }
    mainCategory.subCategories.push({ name });
    await mainCategory.save();
    res.status(201).json(mainCategory);
  } catch (error) {
    res.status(400).json({ message: '서브 카테고리 추가 중 오류 발생', error: error.message });
  }
};

// 서브 카테고리 수정
exports.updateSubCategory = async (req, res) => {
  try {
    const { mainId, subId } = req.params;
    const { name } = req.body;
    const mainCategory = await Category.findById(mainId);
    if (!mainCategory) {
      return res.status(404).json({ message: '메인 카테고리를 찾을 수 없습니다.' });
    }
    const subCategory = mainCategory.subCategories.id(subId);
    if (!subCategory) {
      return res.status(404).json({ message: '서브 카테고리를 찾을 수 없습니다.' });
    }
    subCategory.name = name;
    await mainCategory.save();
    res.status(200).json(mainCategory);
  } catch (error) {
    res.status(400).json({ message: '서브 카테고리 수정 중 오류 발생', error: error.message });
  }
};

// 서브 카테고리 삭제
exports.deleteSubCategory = async (req, res) => {
  try {
    const { mainId, subId } = req.params;
    const mainCategory = await Category.findById(mainId);
    if (!mainCategory) {
      return res.status(404).json({ message: '메인 카테고리를 찾을 수 없습니다.' });
    }
    mainCategory.subCategories.pull(subId); // Mongoose의 pull 메소드로 배열에서 제거
    await mainCategory.save();
    res.status(200).json({ message: '서브 카테고리가 성공적으로 삭제되었습니다.' });
  } catch (error) {
    res.status(500).json({ message: '서브 카테고리 삭제 중 오류 발생', error: error.message });
  }
};