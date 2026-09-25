--!strict

-- M6C.1 Creator Store import proof. These three assets are user-approved and
-- intentionally limited to Common/base-model validation. Do not expand this
-- list until the visual proof passes review.

return table.freeze({
	StorageFolderName = "OneTripImportedAssets",
	ReviewGalleryAttribute = "M6CImportedReviewGallery",
	Assets = table.freeze({
		Couch = table.freeze({
			CargoId = "Couch",
			AssetId = 10710790394,
			SectionId = "Furniture",
			TargetBounds = Vector3.new(10.5, 4.4, 4.1),
			PreserveNaturalColor = true,
			RemoveAllExternalTextures = false,
			ReviewOrder = 1,
		}),
		Refrigerator = table.freeze({
			CargoId = "Refrigerator",
			AssetId = 482124502,
			SectionId = "Appliances",
			TargetBounds = Vector3.new(4.6, 8.0, 4.4),
			PreserveNaturalColor = true,
			RemoveAllExternalTextures = false,
			ReviewOrder = 2,
		}),
		ArcadeCabinet = table.freeze({
			CargoId = "ArcadeCabinet",
			-- User-approved original Freddy/FNAF arcade proof asset. Preserve its
			-- natural appearance; no texture stripping and no generated repaint.
			AssetId = 105044479380665,
			SectionId = "Recreation",
			TargetBounds = Vector3.new(4.8, 8.4, 4.6),
			PreserveNaturalColor = true,
			RemoveAllExternalTextures = false,
			ApplyOneTripArcadePaint = false,
			ReviewOrder = 3,
		}),
	}),
})
