//
//  SearchResultCell.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 23/07/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
  
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let selectedView = UIView(frame: CGRect.zero)
    selectedView.backgroundColor = UIColor(red: 30/255, green: 255/255, blue: 40/255, alpha: 0.5)
    selectedBackgroundView = selectedView
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
}
